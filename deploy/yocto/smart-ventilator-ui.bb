SUMMARY = "Smart Ventilator Qt HMI"
DESCRIPTION = "Qt/QML ventilator HMI simulator with SQLite audit persistence"
LICENSE = "CLOSED"

SRC_URI = "git://example.invalid/smart-ventilator-ui.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

inherit qmake6 systemd

DEPENDS += "qtdeclarative qtquickcontrols2 qtmultimedia qtsql"
RDEPENDS:${PN} += "qtdeclarative-qmlplugins qtquickcontrols2-qmlplugins qtsql-sqlite"

EXTRA_QMAKEVARS_PRE += "APP_VERSION=${PV} BUILD_ID=${SRCPV}"

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/MedicalProject ${D}${bindir}/smart-ventilator-ui

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/deploy/systemd/smart-ventilator-ui.service ${D}${systemd_system_unitdir}/
}

SYSTEMD_SERVICE:${PN} = "smart-ventilator-ui.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"
