FROM public.ecr.aws/lambda/ruby:2.7 as builder

RUN ls
COPY app.rb Gemfile ./

ENV GEM_HOME=${LAMBDA_TASK_ROOT}
RUN bundle install
RUN pwd

FROM alpine:latest as tailscale
WORKDIR /app
ENV TSFILE=tailscale_1.32.2_amd64.tgz
RUN wget https://pkgs.tailscale.com/stable/${TSFILE} && \
  tar xzf ${TSFILE} --strip-components=1

FROM public.ecr.aws/lambda/ruby:2.7
COPY --from=builder /var/task/app.rb /var/task/Gemfile /var/task/Gemfile.lock /var/runtime/
COPY block_serializer.rb /var/runtime/
ENV GEM_HOME=${LAMBDA_TASK_ROOT}
WORKDIR /var/runtime
RUN bundle install
COPY tskey /var/task/tskey
COPY --from=tailscale /app/tailscaled /var/runtime/tailscaled
COPY --from=tailscale /app/tailscale /var/runtime/tailscale
RUN mkdir -p /var/run && ln -s /tmp/tailscale /var/run/tailscale && \
  mkdir -p /var/cache && ln -s /tmp/tailscale /var/cache/tailscale && \
  mkdir -p /var/lib && ln -s /tmp/tailscale /var/lib/tailscale && \
  mkdir -p /var/task && ln -s /tmp/tailscale /var/task/tailscale

CMD ["/var/runtime/app.lambda_handler"]