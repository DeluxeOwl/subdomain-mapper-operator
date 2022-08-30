# ingress-subdomain-operator (IN-PROGRESS)

This operator patches an ingress to automatically create subdomains for services based on annotations.

The services must have the following annotation:

```yaml
annotations:
  automatic-subdomain/ingress: "your-ingress-name"
```

## Requirements

Create the RBAC permissions and the service account

```sh
kubectl apply -f shell-operator-rbac.yaml
```

# TODO

- add more documentation
- add build step for image and testing
- clean up the code
