@{
    RootModule        = 'Install-OSUpdates.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'b1234567-89ab-cdef-0123-456789abcdef'
    Author            = 'John C'
    Description       = 'Automates Windows Server patching via SCCM or WSUS with optional reboot and logging.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Install-OSUpdates')
}
