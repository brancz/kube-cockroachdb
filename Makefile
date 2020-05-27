build: operator/operator

.PHONY: test
test:
	go test -v ./operator/...

operator/operator: $(shell find ./operator -type f -name '*.go')
	go build -v -o operator ./operator/...

operator/metalmatze.de_cockroachdbs.yaml: controller-gen $(shell find ./operator/api/v1alphav1 -type f -name '*.go')
	./controller-gen crd paths="./operator/..." output:crd:artifacts:config=./operator

operator/api/v1alphav1/zz_generated.deepcopy.go: controller-gen $(shell find ./operator/api/v1alphav1 -type f -name '*.go' -not -name '*.deepcopy.go')
	./controller-gen object paths="./operator/..."

controller-gen:
	CGO_ENABLED=0 GO111MODULE="on" go build -o $@ sigs.k8s.io/controller-tools/cmd/controller-gen

examples: examples/basic/basic.yaml examples/simple/simple.yaml examples/pvc/pvc.yaml

examples/basic/basic.yaml: examples/basic/basic.jsonnet kubernetes.libsonnet
	jsonnetfmt -i kubernetes.libsonnet examples/basic/basic.jsonnet
	jsonnet examples/basic/basic.jsonnet | gojsontoyaml > examples/basic/basic.yaml

examples/pvc/pvc.yaml: examples/pvc/pvc.jsonnet kubernetes.libsonnet
	jsonnetfmt -i kubernetes.libsonnet examples/pvc/pvc.jsonnet
	jsonnet examples/pvc/pvc.jsonnet | gojsontoyaml > examples/pvc/pvc.yaml

embedmd:
	GO111MODULE="on" go build -o $@ github.com/campoy/embedmd

docs/content/_index.md: embedmd $(shell find examples/ -name "*.jsonnet")
	embedmd -w `find docs -name "*.md"`

PHONY: .tags
.tags:
	git rev-parse --short HEAD > .tags
