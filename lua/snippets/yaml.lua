local ls = require("luasnip")
local s = ls.snippet
local fmt = require('luasnip.extras.fmt').fmt

local dep_def = [[
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: {{{{.Values.deployment.label}}}}
  name: {{{{.Values.deployment.name}}}}
spec:
  replicas: {{{{.Values.deployment.replicas}}}}
  selector:
    matchLabels:
      app: {{{{.Values.pod.label}}}}
  strategy: {{}}
  template:
    metadata:
      labels:
        app: {{{{.Values.pod.label}}}}
    spec:
      containers:
      - image: {{{{.Values.pod.container_image}}}}
        name: {{{{.Values.pod.container_name}}}}
        resources: {{}}
        livenessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 5
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /healthz
            port: 8080
            httpHeaders:
            - name: Custom-Header
              value: Awesome
          initialDelaySeconds: 5
          periodSeconds: 5
]]

ls.add_snippets("yaml", {
    s("h-deployment", fmt(dep_def, {})),
})
