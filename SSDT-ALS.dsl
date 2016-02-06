// The UX305FA ambient light sensor, for EMlyDinEsH's driver.
//
// I hate the ALS, so it goes in this separate file.

DefinitionBlock ("SSDT-ALS.aml", "SSDT", 1, "hack", "als", 0x00003000)
{
 	External(\_SB.PCI0.LPCB.EC0, DeviceObj)
	External(\_SB.PCI0.LPCB.EC0.RALS, MethodObj)
	External(ATKP, IntObj)
	External(\_SB.ATKD, DeviceObj)	
	External(\_SB.ATKD.IANE, MethodObj)

 	External (RMDT, DeviceObj)
	External (RMDT.PUSH, MethodObj)
	External (RMDT.P1, MethodObj)
	External (RMDT.P2, MethodObj)
	External (RMDT.P3, MethodObj)
	External (RMDT.P4, MethodObj)
	External (RMDT.P5, MethodObj)
	External (RMDT.P6, MethodObj)
	External (RMDT.P7, MethodObj)
	
	Scope (\_SB.PCI0.LPCB.EC0)
       	{
		// Ambient light sensor notification, from EMlyDinEsH
		Method (_QCD, 0, NotSerialized)
		{
			If (ATKP)
			{
				\RMDT.P2("ALS sensor:", ^^^^ATKD.ALSS())
				// This notification code does not appear to be native to this BIOS. I wonder if that is intentional.
				// ^^^^ATKD.IANE (0xC7)
				// What _QCD does call is 0xC6
				^^^^ATKD.IANE (0xC6)
			}
	       	}
	}

	
	Scope (\_SB.ATKD)
	{
	Method (ALSS, 0, NotSerialized)
            {
                Return (^^PCI0.LPCB.EC0.RALS ())
            }
	}
	
}
	
