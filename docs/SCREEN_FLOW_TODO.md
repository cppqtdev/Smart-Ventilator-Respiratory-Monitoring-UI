# ICU Smart Ventilator UI Flow And TODO

## Primary Device Flow

1. Splash Screen
   - Shows Alsons Technology branding, software version, operating hours, and real loading progress.
   - Next: Standby.

2. Standby / Patient Selection
   - Select patient type, recent profile, gender, height, IBW, oxygen, PEEP, and minute-volume presets.
   - Actions: Test & Calibration, Start Ventilation.
   - Next: Patient Setup or Monitoring.

3. Patient Profile Configuration
   - Configure age, gender, height, weight, category, and calculated IBW.
   - Shows recommended tidal volume and respiratory rate.
   - Next: Mode Selection.

4. Ventilation Mode Selection
   - Select and confirm ASV, SIMV, PCV, CPAP, BiPAP, PSV, PRVC, and related modes.
   - Next: Monitoring.

5. Active Monitoring
   - Real-time simulated pressure, flow, volume, CO2, vitals, lung-compliance, and alarm values.
   - Bottom navigation stays visible.

6. Controls
   - Basic, Patient, Advanced, Alarm Limits, and Apnea Backup sections.
   - Parameter knobs update the C++ ventilator controller.

7. Layout
   - Select monitoring layout presets for waveform, lung, loop, and multi-panel arrangements.

8. Events
   - Timeline of mode changes, parameter edits, alarms, and system actions.

9. Alarms
   - Alarm center with critical, warning, and informational rows.
   - Acknowledge flow is connected to the C++ alarm controller.

10. Tools
    - Page 1, Page 2, and Alarm Log utilities with alarm-limit style gauges.

11. System
    - Info, Tests & Calib, Sensors, and Settings.
    - Shows India Standard Time in a 12-hour clock.

12. Shutdown / Safe Standby
    - End flow for safe stop, alarm review, and return to Standby.
    - TODO: add a dedicated confirmation screen for clinical stop workflow.

## Implemented In This Pass

- Real-time India clock backend using `ClockController`.
- Working bottom navigation for Monitoring, Controls, System, Layout, Events, Alarms, Tools, and Modes.
- Controls sidebar switches content instead of staying static.
- System tabs switch content instead of staying static.
- Added Events, Tools, and Layout screens to the QML resource bundle.

## Remaining Production TODO

- Replace demo event rows with a QAbstractListModel backed by SQLite event records.
- Add full shutdown / safe stop confirmation screen.
- Add C++ service interfaces for real pressure, flow, oxygen, battery, touchscreen, fan, and network hardware.
- Add hardware alarm priority arbitration and silence / acknowledge timing rules.
- Add operator authentication for maintenance and service menus.
- Add automated QML interaction tests for every navigation route and critical-action dialog.
- Add clinical validation copy review for all alarm names, units, limits, and suggested settings.
