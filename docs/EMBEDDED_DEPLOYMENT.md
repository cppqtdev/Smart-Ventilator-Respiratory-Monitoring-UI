# Embedded Deployment Checklist

## Yocto

- Add `deploy/yocto/smart-ventilator-ui.bb` to the product layer.
- Replace the placeholder `SRC_URI` with the production repository URL.
- Pin `SRCREV` for release builds.
- Pass `APP_VERSION` and `BUILD_ID` from CI.
- Include the SQLite driver package in the image.

## systemd

- Install `deploy/systemd/smart-ventilator-ui.service`.
- Use `Restart=always` and `WatchdogSec=10` for UI process recovery.
- Run with a read-only root filesystem and writable state/log partitions.
- Keep ventilator safety control outside the UI process.

## Runtime Safety

- Hardware controller must continue safe ventilation or enter safe standby if
  the UI exits.
- Backend heartbeat must alarm the UI when data is stale or disconnected.
- Storage-full/read-only/corrupt states must be visible to the operator and
  logged when possible.
- Audit database must be backed up or exported through a controlled workflow.
