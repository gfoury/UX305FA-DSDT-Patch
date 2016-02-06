DefinitionBlock ("SSDT-HACK.aml", "SSDT", 1, "hack", "hack", 0x00003000)
{
	External(\_SB.PCI0.LPCB.EC0, DeviceObj)
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
}
