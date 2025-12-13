# Generic Lambda Python Dockerfile
# Supports both setup.py and requirements.txt
# Usage: docker build --build-arg HANDLER=app.lambda_handler -f lambda-python.Dockerfile /path/to/lambda/code

FROM public.ecr.aws/lambda/python:3.11

# Accept handler as build argument (can be overridden at build time)
ARG EXEC_SCRIPT=""
ARG SERVICE=""
# Set working directory
WORKDIR ${LAMBDA_TASK_ROOT}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Copy all service code to Lambda task root
COPY . ${LAMBDA_TASK_ROOT}/${SERVICE}/



# Install dependencies - prioritize setup.py, fallback to requirements.txt
RUN if [ -f ${SERVICE}/setup.py ]; then \
    echo "Installing dependencies from setup.py..."; \
    pip install --no-cache-dir "./${SERVICE}" --target "/opt/python"; \
    elif [ -f ${SERVICE}/requirements.txt ]; then \
    echo "Installing dependencies from requirements.txt..."; \
    pip install --upgrade --no-cache-dir -r ${SERVICE}/requirements.txt --target "/opt/python"; \ 
    else \
    echo "No dependency file found (setup.py or requirements.txt). Skipping..."; \
    fi

# Make an optional script executable when provided via build-arg `EXEC_SCRIPT`
RUN if [ -n "${EXEC_SCRIPT}" ] && [ -f "${LAMBDA_TASK_ROOT}/${SERVICE}/${EXEC_SCRIPT}" ]; then \
    echo "Making ${EXEC_SCRIPT} executable"; \
    chmod 755 "${LAMBDA_TASK_ROOT}/${SERVICE}/${EXEC_SCRIPT}"; \
    else \
    echo "No EXEC_SCRIPT provided or file not found; skipping chmod."; \
    fi
RUN echo "Contents of ${LAMBDA_TASK_ROOT}/${SERVICE}/:" && ls -la ${LAMBDA_TASK_ROOT}/${SERVICE}/
RUN echo "Contents of /opt/python/:" && ls -la /opt/python | sed -n '1,20p'
# Set the CMD to your handler (can be overridden at runtime)
# CMD [ "${HANDLER}" ]

# Alternative: If you want handler to be more flexible, use this instead:
# ENTRYPOINT [ "python", "-m", "awslambdaric" ]
# CMD [ "app.lambda_handler" ]
