# Changelog

## [4.1.0](https://github.com/padok-team/terraform-google-gke/compare/v4.0.0...v4.1.0) (2024-03-01)


### Features

* **addons:** add support for the GCS FUSE CSI driver addon ([d796541](https://github.com/padok-team/terraform-google-gke/commit/d796541649a46118ebb8eeb989546cf6e6da90e2))

## [4.0.0](https://github.com/padok-team/terraform-google-gke/compare/v3.1.0...v4.0.0) (2022-12-23)


### ⚠ BREAKING CHANGES

* **encryption:** activate encryption by default, this will recreate your clusters

### Features

* **encryption:** activate encryption by default, this will recreate your clusters ([0c86d7b](https://github.com/padok-team/terraform-google-gke/commit/0c86d7b51d60eead7e32d6fbb76fe155a2fea309))
* **kms:** encrypt gke boot disk and etcd with kms ([c77c4d5](https://github.com/padok-team/terraform-google-gke/commit/c77c4d553d25fff8dff052f2b8904bf436662409))

## [3.1.0](https://github.com/padok-team/terraform-google-gke/compare/v3.0.1...v3.1.0) (2022-09-09)


### Features

* **gke:** set workload_identity_pool as a variable ([7af4405](https://github.com/padok-team/terraform-google-gke/commit/7af440550eff0e5337900c309708c137c1c89f3c))


### Bug Fixes

* **monitoring:** remove WORKLOADS monitoring as this will be deprecated soon ([0a0768f](https://github.com/padok-team/terraform-google-gke/commit/0a0768fd3710e7ad3f805ecb0fe9dcab3c465bc6))
