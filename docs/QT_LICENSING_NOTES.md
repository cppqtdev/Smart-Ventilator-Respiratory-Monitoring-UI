# Qt Licensing Notes

This project currently uses Qt 6.8 modules:

- QtCore
- QtGui
- QtQml
- QtQuick
- QtQuickControls2
- QtSql
- QtMultimedia

For a closed embedded medical product, confirm licensing with legal counsel and
The Qt Company before shipment. LGPL obligations may require dynamic linking,
license notices, access to modified Qt source, and a relinking path for end
users. Static linking, proprietary Qt patches, some embedded tooling, and some
device-management workflows may require a commercial Qt license.

The current qmake project uses Qt Quick Controls Basic style. If additional
modules are added, update this file and the Yocto recipe dependencies.
