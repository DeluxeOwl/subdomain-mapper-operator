# subdomain-mapper-operator (IN-PROGRESS)

This operator patches an ingress to automatically create subdomains for services based on annotations.

The services must have the following annotation:

```yaml
annotations:
  subdomain-mapper/ingress: "your-ingress-name"
```

## Requirements

Create the RBAC permissions and the service account

```sh
kubectl apply -f rbac.yaml
kubectl apply -f operator.yaml
```

# TODO

- add more documentation
- add build step for image and testing
- clean up the code
