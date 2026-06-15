# ICU Smart Ventilator Remaining TODO

Last reviewed: 2026-06-15

## Feature Coverage

The original feature roadmap is implemented at demo level:

- [x] Trends with 1/6/12/24-hour history
- [x] Pressure-volume and flow-volume loops
- [x] Patient admission and persistent patient information
- [x] Nebulizer and heated humidifier controls
- [x] Weaning assessment, RSBI, and SBT workflow
- [x] Clinical CSV export
- [x] Automatic day/night mode
- [x] Frozen waveform cursor measurement
- [x] Inspiratory and expiratory hold maneuvers
- [x] Clinical help and quick reference
- [x] Network and HL7/FHIR status simulation
- [x] Battery and AC power simulation
- [x] Maintenance log
- [x] Multi-patient central dashboard

## Priority 0: Verify Current Implementation

- [ ] Build with the user's working Qt kit.
- [ ] Run every navigation route at 1366x768 and 1920x1080.
- [ ] Verify Trends with an existing and empty SQLite database.
- [ ] Verify P-V and F-V loops during ventilation and freeze mode.
- [ ] Verify Night, Day, and Automatic schedule transitions.
- [ ] Verify nebulizer countdown and automatic completion.
- [ ] Verify SBT completion and automatic failure thresholds.
- [ ] Verify low-battery and critical-battery alarms.
- [ ] Verify state restoration after application restart.
- [ ] Verify CSV export contents and destination.
- [ ] Fix any QML runtime warnings found during testing.

## Priority 1: Complete Demo Workflows

- [x] Add patient admission date-format and required-field validation.
- [x] Add discharge workflow.
- [ ] Add transfer and new-patient confirmation dialogs.
- [x] Add editable nebulizer duration and medication label.
- [x] Add humidifier target/actual temperature and water-level warnings.
- [ ] Add SBT protocol steps, pause/resume, notes, and final clinician outcome.
- [x] Store maneuver results instead of only writing event messages.
- [x] Add amplitude measurement to frozen waveform cursors.
- [x] Add selectable waveform time scale and cursor sample values.
- [ ] Add PDF export; CSV is currently the only format.
- [ ] Add USB destination selection and export failure handling.
- [x] Add alarm/event CSV export.
- [x] Add searchable/filterable clinical reference content.
- [x] Replace hardcoded central-monitor patients with persisted patient records.
- [x] Add maintenance schedule acknowledgement.
- [x] Add maintenance due-date editing and overdue status.
- [ ] Add overdue maintenance alarm escalation.
- [x] Add network configuration fields and simulated connection test results.

## Priority 2: Automated Testing

- [ ] Add C++ unit tests for controllers and SQLite migrations.
- [ ] Add database tests for trends, clinical state, SBT, and maintenance history.
- [ ] Add QML tests for navigation and screen creation.
- [ ] Add tests for alarm acknowledge, silence, and priority behavior.
- [ ] Add tests for SBT auto-stop and battery threshold transitions.
- [ ] Add tests for day/night schedules crossing midnight.
- [ ] Add export validation tests.
- [ ] Add restart/persistence integration tests.
- [ ] Add CI builds for macOS and the intended embedded target.

## Priority 3: Hardware Integration

- [ ] Define pressure, flow, oxygen, CO2, SpO2, battery, and power interfaces.
- [ ] Replace simulated waveform and measurement generation with device adapters.
- [ ] Add serial/CAN/Ethernet transport health and reconnect handling.
- [ ] Connect nebulizer and humidifier controls to hardware drivers.
- [ ] Connect inspiratory/expiratory holds to the ventilation control firmware.
- [ ] Connect battery runtime and AC state to the battery-management controller.
- [ ] Connect network status to actual interfaces and HL7/FHIR services.
- [ ] Replace simulated diagnostics and calibration with hardware self-tests.
- [ ] Add watchdog, fail-safe state, and communication-loss behavior.
- [ ] Add hardware alarm outputs for buzzer and visual indicators.

## Priority 4: Security And Data Integrity

- [ ] Replace PIN SHA-256 hashing with Argon2, scrypt, or bcrypt.
- [ ] Add account lockout and failed-login audit events.
- [ ] Add user identity to every clinical and settings audit record.
- [ ] Add role authorization for service, maintenance, export, and shutdown.
- [ ] Encrypt clinical data at rest, for example with SQLCipher.
- [ ] Add database backup, restore, retention, and corruption recovery.
- [ ] Add signed export files and integrity verification.
- [ ] Protect system time changes and record them in the audit trail.
- [ ] Add session timeout and forced reauthentication for critical actions.

## Priority 5: Clinical And Regulatory Validation

- [ ] Clinical review of all mode descriptions and recommended values.
- [ ] Clinical review of alarm names, units, limits, and priorities.
- [ ] Define validated SBT inclusion, failure, and completion criteria.
- [ ] Define validated humidifier and nebulizer safety limits.
- [ ] Complete ISO 14971 hazard analysis and risk controls.
- [ ] Create IEC 62304 requirements, architecture, traceability, and test records.
- [ ] Perform IEC 62366-1 usability engineering and formative testing.
- [ ] Complete IEC 60601-1-8 alarm escalation and priority validation.
- [ ] Complete FDA 21 CFR Part 11 electronic-record controls if applicable.
- [ ] Establish clinical data retention and privacy requirements.

## Priority 6: Accessibility And Localization

- [ ] Run contrast checks for Day and Night palettes.
- [ ] Ensure alarms never rely on color alone.
- [ ] Verify all touch targets for gloved operation.
- [ ] Add keyboard/focus navigation for service use.
- [ ] Add screen-reader labels where the deployment platform supports them.
- [ ] Integrate Qt translation files and replace user-facing literals with `qsTr`.
- [ ] Validate layouts with longer translated strings.
- [ ] Add configurable units and locale-aware number/date formatting.

## Priority 7: Performance And Deployment

- [ ] Profile waveform and loop rendering on target hardware.
- [ ] Limit or downsample large trend queries.
- [ ] Add SQLite indexes and retention cleanup for long-running devices.
- [ ] Measure startup time, memory use, and CPU use.
- [ ] Add structured logs and diagnostic bundle export.
- [ ] Add production versioning and database schema migration versions.
- [ ] Add signed release packaging and update/rollback workflow.
- [ ] Document device provisioning, calibration, service, and recovery procedures.

## Definition Of Done

A feature is not production-complete until it has:

- [ ] Approved clinical requirements.
- [ ] Risk controls and failure behavior.
- [ ] Hardware or service integration.
- [ ] Persistence and audit coverage.
- [ ] Automated tests.
- [ ] Usability and accessibility validation.
- [ ] Release and maintenance documentation.
