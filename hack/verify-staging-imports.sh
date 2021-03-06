#!/bin/bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/..
source "${KUBE_ROOT}/hack/lib/init.sh"

kube::golang::setup_env


for dep in $(ls -1 ${KUBE_ROOT}/staging/src/k8s.io/); do
	if go list -f {{.Deps}} ./vendor/k8s.io/${dep}/... | tr " " '\n' | grep k8s.io/kubernetes | grep -v 'k8s.io/kubernetes/vendor' | LC_ALL=C sort -u | grep -e "."; then
		echo "${dep} has a cyclical dependency"
		exit 1
	fi
done

if grep -rq '// import "k8s.io/kubernetes/' 'staging/'; then
	echo 'file has "// import "k8s.io/kubernetes/"'
	exit 1
fi

exit 0