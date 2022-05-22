FROM 371334089058.dkr.ecr.ap-south-1.amazonaws.com/circom:latest
WORKDIR /tmp
COPY . .
#RUN /bin/bash -c "source /root/.cargo/env" 
RUN bash -c " export PATH="$PATH:/root/.cargo/bin" && npm install &&npm run test"
CMD ["echo", "SUCCESS"]
