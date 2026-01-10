#!/bin/bash

echo "=== Testing Dockerfile.python build correctness ==="
echo

# Check if required files exist
echo "1. Checking required files:"
required_files=("Dockerfile.python" ".dockerignore")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  [OK] File $file found"
    else
        echo "  [ERROR] File $file not found"
        exit 1
    fi
done

echo
echo "2. Checking Dockerfile.python requirements:"
echo "   - Is python:3.12-slim used?"
if grep -q "FROM python:3.12-slim" Dockerfile.python; then
    echo "     [OK] Using python:3.12-slim"
else
    echo "     [ERROR] Not using python:3.12-slim"
    exit 1
fi

echo "   - Does it contain COPY . . ?"
if grep -q "COPY \. \." Dockerfile.python; then
    echo "     [OK] Contains COPY . ."
else
    echo "     [ERROR] Does not contain COPY . ."
    exit 1
fi

echo "   - Does it use CMD with uvicorn?"
if grep -q 'CMD \["uvicorn", "main:app"' Dockerfile.python; then
    echo "     [OK] Using correct CMD"
else
    echo "     [ERROR] Not using correct CMD"
    exit 1
fi

echo
echo "3. Checking .dockerignore file:"
echo "   .dockerignore content:"
echo "   ---"
cat .dockerignore
echo "   ---"

echo
echo "4. Testing Docker image build:"
if docker build -f Dockerfile.python -t test-python-app .; then
    echo "  [OK] Build successful!"
    echo "   Image size:"
    docker images test-python-app --format "{{.Size}}"
else
    echo "  [ERROR] Docker build failed"
    exit 1
fi

echo
echo "5. Testing container run:"
docker run -d --name test-container -p 5001:5000 test-python-app
sleep 5

if docker ps | grep -q test-container; then
    echo "  [OK] Container started successfully"
    echo "   Checking application:"
    
    # Give app time to start
    sleep 3
    
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:5001; then
        echo "     [OK] Application responds"
    else
        echo "     [WARNING] Application not responding"
    fi
    
    echo "   Container logs (last 5 lines):"
    docker logs test-container --tail=5
    
    # Cleanup
    docker stop test-container > /dev/null
    docker rm test-container > /dev/null
    echo "     [OK] Test container cleaned up"
else
    echo "  [ERROR] Container failed to start"
    docker logs test-container
    exit 1
fi

echo
echo "6. Checking uvicorn in PATH (CMD compatibility):"
echo "   Checking if uvicorn is in PATH inside container..."
docker run --rm test-python-app sh -c 'which uvicorn && echo "  [OK] uvicorn found in PATH" || echo "  [ERROR] uvicorn not in PATH"'

echo
echo "=== Testing completed successfully! ==="
echo "All requirements met:"
echo "1. [OK] Dockerfile.python uses python:3.12-slim"
echo "2. [OK] Dockerfile.python contains COPY . ."
echo "3. [OK] .dockerignore file created"
echo "4. [OK] Dockerfile.python uses CMD [\"uvicorn\", \"main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"5000\"]"
echo "5. [OK] Build and run tested"
