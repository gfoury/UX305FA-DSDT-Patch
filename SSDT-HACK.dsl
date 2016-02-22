DefinitionBlock ("SSDT-HACK.aml", "SSDT", 1, "hack", "hack", 0x00003000)
{
	External(\_SB.PCI0.LPCB.EC0, DeviceObj)
	External(\_SB.PCI0.EHC1, DeviceObj)
	External(\_SB.PCI0.EHC2, DeviceObj)
	External(\_SB.PCI0.XHC, DeviceObj)
	External(\_SB.PCI0.HDEF, DeviceObj)
	External(\_SB.PCI0.HDAU, DeviceObj)
	External(\_SB.PCI0.IGPU, DeviceObj)
	External(ATKP, IntObj)
	External(\_SB.ATKD, DeviceObj)
	External(\_SB.ATKD.IANE, MethodObj)
	External(XPRW, MethodObj)

	External (RMDT, DeviceObj)
	External (RMDT.PUSH, MethodObj)
	External (RMDT.P1, MethodObj)
	External (RMDT.P2, MethodObj)
	External (RMDT.P3, MethodObj)
	External (RMDT.P4, MethodObj)
	External (RMDT.P5, MethodObj)
	External (RMDT.P6, MethodObj)
	External (RMDT.P7, MethodObj)

	// Brightness keys
	Scope (\_SB.PCI0.LPCB.EC0)
       	{
		Method (_Q0E, 0, NotSerialized)  // _Qxx: EC Query
		{
			If (ATKP)
			{
				^^^^ATKD.IANE (0x20)
			}
		}

		Method (_Q0F, 0, NotSerialized)  // _Qxx: EC Query
	       	{
			If (ATKP)
			{
				^^^^ATKD.IANE (0x10)
			 }

		}
	}

	// The native GPRW definition is renamed to XPRW, so
	// GPRW calls from all over the BIOS land here.
	Method(GPRW, 2, NotSerialized)
	{
		\RMDT.P3("GPRW", Arg0, Arg1)
		// USB calls this as GPRW(0x6d, 0x03).
		// GLAN and HDEF call this as GPRW(0x6d, 04)
		// We only care about USB, I think.
		//
		// No, I was wrong. GLAN causes instant wake too when AC-powered.
		// Fix all 0x6d.
		If (LEqual(Arg0, 0x6d))
		{
			//If (LEqual(Arg1, 0x03))
			//{
				// It doesn't look like there are
				// side-effects, but call anyway.
				XPRW(Arg0, Arg1)
				// Avoid instant wake from USB.
				// and GLAN
				Return (Package (0x02) { 0x6D, 0x00 })
			//}
		}
		Return (XPRW(Arg0, Arg1))
	}

/*	Scope(_SB.PCI0.EHC1) {
	    Method (_DSM, 4, NotSerialized)
            {
                If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
                Return (Package()
                {
                    "subsystem-id", Buffer() { 0x70, 0x72, 0x00, 0x00 },
                    "subsystem-vendor-id", Buffer() { 0x86, 0x80, 0x00, 0x00 },
                    "AAPL,current-available", 2100,
                    "AAPL,current-extra", 2200,
                    "AAPL,current-extra-in-sleep", 1600,
                    "AAPL,device-internal", 0x02,
                    "AAPL,max-port-current-in-sleep", 2100,
                })
            }
	}
	Scope(_SB.PCI0.EHC2) {
	    Method (_DSM, 4, NotSerialized)
            {
                If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
                Return (Package()
                {
                    "subsystem-id", Buffer() { 0x70, 0x72, 0x00, 0x00 },
                    "subsystem-vendor-id", Buffer() { 0x86, 0x80, 0x00, 0x00 },
                    "AAPL,current-available", 2100,
                    "AAPL,current-extra", 2200,
                    "AAPL,current-extra-in-sleep", 1600,
                    "AAPL,device-internal", 0x02,
                    "AAPL,max-port-current-in-sleep", 2100,
                })
            }
	} */
	Scope(_SB.PCI0.XHC) {
	    Method (_DSM, 4, NotSerialized)
            {
                If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
                Return (Package()
                {
                    "subsystem-id", Buffer() { 0x70, 0x72, 0x00, 0x00 },
                    "subsystem-vendor-id", Buffer() { 0x86, 0x80, 0x00, 0x00 },
                    "AAPL,current-available", 2100,
                    "AAPL,current-extra", 2200,
                    "AAPL,current-extra-in-sleep", 1600,
                    "AAPL,device-internal", 0x02,
                    "AAPL,max-port-current-in-sleep", 2100,
                })
            }
	}
	Scope(_SB.PCI0.HDEF) {
	    Method (_DSM, 4, NotSerialized)
        {
            If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
            Return (Package()
            {
                "layout-id", Buffer() { 3, 0x00, 0x00, 0x00 },
                "hda-gfx", Buffer() { "onboard-1" },
                "PinConfigurations", Buffer() { },
                //"MaximumBootBeepVolume", 77,
            })
        }
	}
    Scope(_SB.PCI0.IGPU) {
        Method (_DSM, 4, NotSerialized)
        {
            If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
            Return(Package()
            {
                "hda-gfx", Buffer() { "onboard-1" },
            })
        }
    }
    Scope(_SB.PCI0.HDAU) {
        Method (_DSM, 4, NotSerialized)
        {
            If (LEqual (Arg2, Zero)) { Return (Buffer() { 0x03 } ) }
            Return(Package()
            {
                "hda-gfx", Buffer() { "onboard-1" },
            })
        }

    }

}
