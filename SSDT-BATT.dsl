
DefinitionBlock ("SSDT-BATT.aml", "SSDT", 1, "hack", "batt", 0x00003000)
{
    External(\_SB.PCI0.LPCB.EC0, DeviceObj)
    External(\_SB.PCI0.BAT0, DeviceObj)	 
    External(BSLF, IntObj)
    External(CHGS, MethodObj)
    External(MBLF, IntObj)
    
      // No override
    Method (B1B2, 2, NotSerialized) 
    { 
        Return (Or (Arg0, ShiftLeft (Arg1, 8))) 
    }
    
Scope (_SB.PCI0.LPCB.EC0) {
    External(ECAV, MethodObj)
    External(RDBT, IntObj)
    External(RDWT, IntObj)
    External(RCBT, IntObj)
    External(RDQK, IntObj)

			   
    External(RDBL, IntObj)
    
    External(RDWD, IntObj)
    External(WRBL, IntObj)
    External(WRWD, IntObj)    
    External(WRBT, IntObj)    
    External(MUEC, MutexObj)
    External(SBBY, IntObj)
    External(SDBT, IntObj)    
    External(WRQK, IntObj)    
    
    External(SWTC, MethodObj)
    External(DAT0, FieldUnitObj)
    External(ECOR, OpRegionObj)
    External(SMBX, OpRegionObj)    
    External(SMB2, OpRegionObj)
    
    External(DAT1, FieldUnitObj)   
    External(DA20, FieldUnitObj)       
    External(DA21, FieldUnitObj) 
    
    External(BATP, MethodObj)
    External(GBTT, MethodObj)
    External(ACAP, MethodObj)
    
    External(EB0S, FieldUnitObj)
    External(B0DV, FieldUnitObj)      

        // Override TACH
        Method (TACH, 1, Serialized)
        {
            Name (T_0, Zero)  // T_x: Emitted by ASL Compiler
            If (ECAV ())
            {
                While (One)
                {
                    Store (Arg0, T_0)
                    If (LEqual (T_0, Zero))
                    {
                        Store (B1B2(TH00,TH01), Local0)
                        Break
                    }
                    Else
                    {
                        If (LEqual (T_0, One))
                        {
                            Store (B1B2(TH10,TH11), Local0)
                            Break
                        }
                        Else
                        {
                            Return (Ones)
                        }
                    }

                    Break
                }

                Multiply (Local0, 0x02, Local0)
                If (LNotEqual (Local0, Zero))
                {
                    Divide (0x0041CDB4, Local0, Local1, Local0)
                    Return (Local0)
                }
                Else
                {
                    Return (Ones)
                }
            }
            Else
            {
                Return (Ones)
            }
        }

	// Override BIFA
        Method (BIFA, 0, NotSerialized)
        {
            If (ECAV ())
            {
                If (BSLF)
                {
                    Store (B1B2(B1S0,B1S1), Local0)
                }
                Else
                {
                    Store (B1B2(B0S0,B0S1), Local0)
                }
            }
            Else
            {
                Store (Ones, Local0)
            }

            Return (Local0)
        }

	// Override SMBR
        Method (SMBR, 3, Serialized)
        {
            Store (Package (0x03)
                {
                    0x07, 
                    Zero, 
                    Zero
                }, Local0)
            If (LNot (ECAV ()))
            {
                Return (Local0)
            }

            If (LNotEqual (Arg0, RDBL))
            {
                If (LNotEqual (Arg0, RDWD))
                {
                    If (LNotEqual (Arg0, RDBT))
                    {
                        If (LNotEqual (Arg0, RCBT))
                        {
                            If (LNotEqual (Arg0, RDQK))
                            {
                                Return (Local0)
                            }
                        }
                    }
                }
            }

            Acquire (MUEC, 0xFFFF)
            Store (PRTC, Local1)
            Store (Zero, Local2)
            While (LNotEqual (Local1, Zero))
            {
                Stall (0x0A)
                Increment (Local2)
                If (LGreater (Local2, 0x03E8))
                {
                    Store (SBBY, Index (Local0, Zero))
                    Store (Zero, Local1)
                }
                Else
                {
                    Store (PRTC, Local1)
                }
            }

            If (LLessEqual (Local2, 0x03E8))
            {
                ShiftLeft (Arg1, One, Local3)
                Or (Local3, One, Local3)
                Store (Local3, ADDR)
                If (LNotEqual (Arg0, RDQK))
                {
                    If (LNotEqual (Arg0, RCBT))
                    {
                        Store (Arg2, CMDB)
                    }
                }

                WRBA(Zero)
                Store (Arg0, PRTC)
                Store (SWTC (Arg0), Index (Local0, Zero))
                If (LEqual (DerefOf (Index (Local0, Zero)), Zero))
                {
                    If (LEqual (Arg0, RDBL))
                    {
                        Store (BCNT, Index (Local0, One))
                        Store (RDBA(), Index (Local0, 0x02))
                    }

                    If (LEqual (Arg0, RDWD))
                    {
                        Store (0x02, Index (Local0, One))
                        Store (B1B2(T2B0,T2B1), Index (Local0, 0x02))
                    }

                    If (LEqual (Arg0, RDBT))
                    {
                        Store (One, Index (Local0, One))
                        Store (DAT0, Index (Local0, 0x02))
                    }

                    If (LEqual (Arg0, RCBT))
                    {
                        Store (One, Index (Local0, One))
                        Store (DAT0, Index (Local0, 0x02))
                    }
                }
            }

            Release (MUEC)
            Return (Local0)
        }

	// Override SMBW
        Method (SMBW, 5, Serialized)
        {
            Store (Package (0x01)
                {
                    0x07
                }, Local0)
            If (LNot (ECAV ()))
            {
                Return (Local0)
            }

            If (LNotEqual (Arg0, WRBL))
            {
                If (LNotEqual (Arg0, WRWD))
                {
                    If (LNotEqual (Arg0, WRBT))
                    {
                        If (LNotEqual (Arg0, SDBT))
                        {
                            If (LNotEqual (Arg0, WRQK))
                            {
                                Return (Local0)
                            }
                        }
                    }
                }
            }

            Acquire (MUEC, 0xFFFF)
            Store (PRTC, Local1)
            Store (Zero, Local2)
            While (LNotEqual (Local1, Zero))
            {
                Stall (0x0A)
                Increment (Local2)
                If (LGreater (Local2, 0x03E8))
                {
                    Store (SBBY, Index (Local0, Zero))
                    Store (Zero, Local1)
                }
                Else
                {
                    Store (PRTC, Local1)
                }
            }

            If (LLessEqual (Local2, 0x03E8))
            {
                WRBA(Zero)
                ShiftLeft (Arg1, One, Local3)
                Store (Local3, ADDR)
                If (LNotEqual (Arg0, WRQK))
                {
                    If (LNotEqual (Arg0, SDBT))
                    {
                        Store (Arg2, CMDB)
                    }
                }

                If (LEqual (Arg0, WRBL))
                {
                    Store (Arg3, BCNT)
                    WRBA(Arg4)
                }

                If (LEqual (Arg0, WRWD))
                {
                    Store(Arg4,T2B0) Store(ShiftRight(Arg4,8),T2B1)
                }

                If (LEqual (Arg0, WRBT))
                {
                    Store (Arg4, DAT0)
                }

                If (LEqual (Arg0, SDBT))
                {
                    Store (Arg4, DAT0)
                }

                Store (Arg0, PRTC)
                Store (SWTC (Arg0), Index (Local0, Zero))
            }

            Release (MUEC)
            Return (Local0)
        }


	    // NOT an override
            Method (RDBA, 0, Serialized)
            {
                Name (TEMP, Buffer(0x20) { })
                Store (BA00, Index(TEMP, 0x00))
                Store (BA01, Index(TEMP, 0x01))
                Store (BA02, Index(TEMP, 0x02))
                Store (BA03, Index(TEMP, 0x03))
                Store (BA04, Index(TEMP, 0x04))
                Store (BA05, Index(TEMP, 0x05))
                Store (BA06, Index(TEMP, 0x06))
                Store (BA07, Index(TEMP, 0x07))
                Store (BA08, Index(TEMP, 0x08))
                Store (BA09, Index(TEMP, 0x09))
                Store (BA0A, Index(TEMP, 0x0A))
                Store (BA0B, Index(TEMP, 0x0B))
                Store (BA0C, Index(TEMP, 0x0C))
                Store (BA0D, Index(TEMP, 0x0D))
                Store (BA0E, Index(TEMP, 0x0E))
                Store (BA0F, Index(TEMP, 0x0F))
                Store (BA10, Index(TEMP, 0x10))
                Store (BA11, Index(TEMP, 0x11))
                Store (BA12, Index(TEMP, 0x12))
                Store (BA13, Index(TEMP, 0x13))
                Store (BA14, Index(TEMP, 0x14))
                Store (BA15, Index(TEMP, 0x15))
                Store (BA16, Index(TEMP, 0x16))
                Store (BA17, Index(TEMP, 0x17))
                Store (BA18, Index(TEMP, 0x18))
                Store (BA19, Index(TEMP, 0x19))
                Store (BA1A, Index(TEMP, 0x1A))
                Store (BA1B, Index(TEMP, 0x1B))
                Store (BA1C, Index(TEMP, 0x1C))
                Store (BA1D, Index(TEMP, 0x1D))
                Store (BA1E, Index(TEMP, 0x1E))
                Store (BA1F, Index(TEMP, 0x1F))
                Return (TEMP)
            }
	    // NOT an override
            Method (WRBA, 1, Serialized)
            {
                Name (TEMP, Buffer(0x20) { })
                Store (Arg0, TEMP)
                Store (DerefOf(Index(TEMP, 0x00)), BA00)
                Store (DerefOf(Index(TEMP, 0x01)), BA01)
                Store (DerefOf(Index(TEMP, 0x02)), BA02)
                Store (DerefOf(Index(TEMP, 0x03)), BA03)
                Store (DerefOf(Index(TEMP, 0x04)), BA04)
                Store (DerefOf(Index(TEMP, 0x05)), BA05)
                Store (DerefOf(Index(TEMP, 0x06)), BA06)
                Store (DerefOf(Index(TEMP, 0x07)), BA07)
                Store (DerefOf(Index(TEMP, 0x08)), BA08)
                Store (DerefOf(Index(TEMP, 0x09)), BA09)
                Store (DerefOf(Index(TEMP, 0x0A)), BA0A)
                Store (DerefOf(Index(TEMP, 0x0B)), BA0B)
                Store (DerefOf(Index(TEMP, 0x0C)), BA0C)
                Store (DerefOf(Index(TEMP, 0x0D)), BA0D)
                Store (DerefOf(Index(TEMP, 0x0E)), BA0E)
                Store (DerefOf(Index(TEMP, 0x0F)), BA0F)
                Store (DerefOf(Index(TEMP, 0x10)), BA10)
                Store (DerefOf(Index(TEMP, 0x11)), BA11)
                Store (DerefOf(Index(TEMP, 0x12)), BA12)
                Store (DerefOf(Index(TEMP, 0x13)), BA13)
                Store (DerefOf(Index(TEMP, 0x14)), BA14)
                Store (DerefOf(Index(TEMP, 0x15)), BA15)
                Store (DerefOf(Index(TEMP, 0x16)), BA16)
                Store (DerefOf(Index(TEMP, 0x17)), BA17)
                Store (DerefOf(Index(TEMP, 0x18)), BA18)
                Store (DerefOf(Index(TEMP, 0x19)), BA19)
                Store (DerefOf(Index(TEMP, 0x1A)), BA1A)
                Store (DerefOf(Index(TEMP, 0x1B)), BA1B)
                Store (DerefOf(Index(TEMP, 0x1C)), BA1C)
                Store (DerefOf(Index(TEMP, 0x1D)), BA1D)
                Store (DerefOf(Index(TEMP, 0x1E)), BA1E)
                Store (DerefOf(Index(TEMP, 0x1F)), BA1F)
            }

// Override Field ECOR
            Field (ECOR, ByteAcc, Lock, Preserve)
            {
                Offset (0x04), 
                CMD1,   8, 
                CDT1,   8, 
                CDT2,   8, 
                CDT3,   8, 
                Offset (0x80), 
                Offset (0x81), 
                Offset (0x82), 
                Offset (0x83), 
                EB0R,   8, 
                EB1R,   8, 
                EPWF,   8, 
                Offset (0x87), 
                Offset (0x88), 
                Offset (0x89), 
                Offset (0x8A), 
                HKEN,   1, 
                Offset (0x93), 
                TH00,8,TH01,8, 
                TH10,8,TH11,8, 
                TSTP,   8, 
                Offset (0x9C), 
                CDT4,   8, 
                CDT5,   8, 
                Offset (0xA0), 
                Offset (0xA1), 
                Offset (0xA2), 
                Offset (0xA3), 
                EACT,   8, 
                TH1R,   8, 
                TH1L,   8, 
                TH0R,   8, 
                TH0L,   8, 
                Offset (0xB0), 
                B0PN,   16, 
                Offset (0xB4), 
                Offset (0xB6), 
                Offset (0xB8), 
                Offset (0xBA), 
                Offset (0xBC), 
                Offset (0xBE), 
                B0TM,   16, 
                B0C1,   16, 
                B0C2,   16, 
                XC30,8,XC31,8, 
                B0C4,   16, 
                Offset (0xD0), 
                B1PN,   16, 
                Offset (0xD4), 
                Offset (0xD6), 
                Offset (0xD8), 
                Offset (0xDA), 
                Offset (0xDC), 
                Offset (0xDE), 
                B1TM,   16, 
                B1C1,   16, 
                B1C2,   16, 
                YC30,8,YC31,8, 
                B1C4,   16, 
                Offset (0xF0), 
                Offset (0xF2), 
                Offset (0xF4), 
                B0S0,8,B0S1,8, 
                Offset (0xF8), 
                Offset (0xFA), 
                Offset (0xFC), 
                B1S0,8,B1S1,8
            }



	    // Override Field SMBX
            Field (SMBX, ByteAcc, NoLock, Preserve)
            {
                PRTC,   8, 
                SSTS,   5, 
                    ,   1, 
                ALFG,   1, 
                CDFG,   1, 
                ADDR,   8, 
                CMDB,   8, 
                //BDAT, 256,
BA00,8,BA01,8,BA02,8,BA03,8,
BA04,8,BA05,8,BA06,8,BA07,8,
BA08,8,BA09,8,BA0A,8,BA0B,8,
BA0C,8,BA0D,8,BA0E,8,BA0F,8,
BA10,8,BA11,8,BA12,8,BA13,8,
BA14,8,BA15,8,BA16,8,BA17,8,
BA18,8,BA19,8,BA1A,8,BA1B,8,
BA1C,8,BA1D,8,BA1E,8,BA1F,8
, 
                BCNT,   8, 
                    ,   1, 
                ALAD,   7, 
                ALD0,   8, 
                ALD1,   8
            }

        // Override Field SMBX (again)
            Field (SMBX, ByteAcc, NoLock, Preserve)
            {
                Offset (0x04), 
                T2B0,8,T2B1,8
            }
        

	    // Override Field SMB2
            Field (SMB2, ByteAcc, NoLock, Preserve)
            {
                PRT2,   8, 
                SST2,   5, 
                    ,   1, 
                ALF2,   1, 
                CDF2,   1, 
                ADD2,   8, 
                CMD2,   8, 
                //BDA2, 256,
BB00,8,BB01,8,BB02,8,BB03,8,
BB04,8,BB05,8,BB06,8,BB07,8,
BB08,8,BB09,8,BB0A,8,BB0B,8,
BB0C,8,BB0D,8,BB0E,8,BB0F,8,
BB10,8,BB11,8,BB12,8,BB13,8,
BB14,8,BB15,8,BB16,8,BB17,8,
BB18,8,BB19,8,BB1A,8,BB1B,8,
BB1C,8,BB1D,8,BB1E,8,BB1F,8
, 
                BCN2,   8, 
                    ,   1, 
                ALA2,   7, 
                ALR0,   8, 
                ALR1,   8
            }

	// Override ECSB
        Method (ECSB, 7, NotSerialized)
        {
            Store (Package (0x05)
                {
                    0x11, 
                    Zero, 
                    Zero, 
                    Zero, 
                    Buffer (0x20) {}
                }, Local1)
            If (LGreater (Arg0, One))
            {
                Return (Local1)
            }

            If (ECAV ())
            {
                Acquire (MUEC, 0xFFFF)
                If (LEqual (Arg0, Zero))
                {
                    Store (PRTC, Local0)
                }
                Else
                {
                    Store (PRT2, Local0)
                }

                Store (Zero, Local2)
                While (LNotEqual (Local0, Zero))
                {
                    Stall (0x0A)
                    Increment (Local2)
                    If (LGreater (Local2, 0x03E8))
                    {
                        Store (SBBY, Index (Local1, Zero))
                        Store (Zero, Local0)
                    }
                    Else
                    {
                        If (LEqual (Arg0, Zero))
                        {
                            Store (PRTC, Local0)
                        }
                        Else
                        {
                            Store (PRT2, Local0)
                        }
                    }
                }

                If (LLessEqual (Local2, 0x03E8))
                {
                    If (LEqual (Arg0, Zero))
                    {
                        Store (Arg2, ADDR)
                        Store (Arg3, CMDB)
                        If (LOr (LEqual (Arg1, 0x0A), LEqual (Arg1, 0x0B)))
                        {
                            Store (DerefOf (Index (Arg6, Zero)), BCNT)
                            WRBA(DerefOf (Index (Arg6, One)))
                        }
                        Else
                        {
                            Store (Arg4, DAT0)
                            Store (Arg5, DAT1)
                        }

                        Store (Arg1, PRTC)
                    }
                    Else
                    {
                        Store (Arg2, ADD2)
                        Store (Arg3, CMD2)
                        If (LOr (LEqual (Arg1, 0x0A), LEqual (Arg1, 0x0B)))
                        {
                            Store (DerefOf (Index (Arg6, Zero)), BCN2)
                            WRBB(DerefOf (Index (Arg6, One)))
                        }
                        Else
                        {
                            Store (Arg4, DA20)
                            Store (Arg5, DA21)
                        }

                        Store (Arg1, PRT2)
                    }

                    Store (0x7F, Local0)
                    If (LEqual (Arg0, Zero))
                    {
                        While (PRTC)
                        {
                            Sleep (One)
                            Decrement (Local0)
                        }
                    }
                    Else
                    {
                        While (PRT2)
                        {
                            Sleep (One)
                            Decrement (Local0)
                        }
                    }

                    If (Local0)
                    {
                        If (LEqual (Arg0, Zero))
                        {
                            Store (SSTS, Local0)
                            Store (DAT0, Index (Local1, One))
                            Store (DAT1, Index (Local1, 0x02))
                            Store (BCNT, Index (Local1, 0x03))
                            Store (RDBA(), Index (Local1, 0x04))
                        }
                        Else
                        {
                            Store (SST2, Local0)
                            Store (DA20, Index (Local1, One))
                            Store (DA21, Index (Local1, 0x02))
                            Store (BCN2, Index (Local1, 0x03))
                            Store (RDBB(), Index (Local1, 0x04))
                        }

                        And (Local0, 0x1F, Local0)
                        If (Local0)
                        {
                            Add (Local0, 0x10, Local0)
                        }

                        Store (Local0, Index (Local1, Zero))
                    }
                    Else
                    {
                        Store (0x10, Index (Local1, Zero))
                    }
                }

                Release (MUEC)
            }

            Return (Local1)
        }

	    // Not an override
            Method (RDBB, 0, Serialized)
            {
                Name (TEMP, Buffer(0x20) { })
                Store (BB00, Index(TEMP, 0x00))
                Store (BB01, Index(TEMP, 0x01))
                Store (BB02, Index(TEMP, 0x02))
                Store (BB03, Index(TEMP, 0x03))
                Store (BB04, Index(TEMP, 0x04))
                Store (BB05, Index(TEMP, 0x05))
                Store (BB06, Index(TEMP, 0x06))
                Store (BB07, Index(TEMP, 0x07))
                Store (BB08, Index(TEMP, 0x08))
                Store (BB09, Index(TEMP, 0x09))
                Store (BB0A, Index(TEMP, 0x0A))
                Store (BB0B, Index(TEMP, 0x0B))
                Store (BB0C, Index(TEMP, 0x0C))
                Store (BB0D, Index(TEMP, 0x0D))
                Store (BB0E, Index(TEMP, 0x0E))
                Store (BB0F, Index(TEMP, 0x0F))
                Store (BB10, Index(TEMP, 0x10))
                Store (BB11, Index(TEMP, 0x11))
                Store (BB12, Index(TEMP, 0x12))
                Store (BB13, Index(TEMP, 0x13))
                Store (BB14, Index(TEMP, 0x14))
                Store (BB15, Index(TEMP, 0x15))
                Store (BB16, Index(TEMP, 0x16))
                Store (BB17, Index(TEMP, 0x17))
                Store (BB18, Index(TEMP, 0x18))
                Store (BB19, Index(TEMP, 0x19))
                Store (BB1A, Index(TEMP, 0x1A))
                Store (BB1B, Index(TEMP, 0x1B))
                Store (BB1C, Index(TEMP, 0x1C))
                Store (BB1D, Index(TEMP, 0x1D))
                Store (BB1E, Index(TEMP, 0x1E))
                Store (BB1F, Index(TEMP, 0x1F))
                Return (TEMP)
            }
	    // Not an override
            Method (WRBB, 1, Serialized)
            {
                Name (TEMP, Buffer(0x20) { })
                Store (Arg0, TEMP)
                Store (DerefOf(Index(TEMP, 0x00)), BB00)
                Store (DerefOf(Index(TEMP, 0x01)), BB01)
                Store (DerefOf(Index(TEMP, 0x02)), BB02)
                Store (DerefOf(Index(TEMP, 0x03)), BB03)
                Store (DerefOf(Index(TEMP, 0x04)), BB04)
                Store (DerefOf(Index(TEMP, 0x05)), BB05)
                Store (DerefOf(Index(TEMP, 0x06)), BB06)
                Store (DerefOf(Index(TEMP, 0x07)), BB07)
                Store (DerefOf(Index(TEMP, 0x08)), BB08)
                Store (DerefOf(Index(TEMP, 0x09)), BB09)
                Store (DerefOf(Index(TEMP, 0x0A)), BB0A)
                Store (DerefOf(Index(TEMP, 0x0B)), BB0B)
                Store (DerefOf(Index(TEMP, 0x0C)), BB0C)
                Store (DerefOf(Index(TEMP, 0x0D)), BB0D)
                Store (DerefOf(Index(TEMP, 0x0E)), BB0E)
                Store (DerefOf(Index(TEMP, 0x0F)), BB0F)
                Store (DerefOf(Index(TEMP, 0x10)), BB10)
                Store (DerefOf(Index(TEMP, 0x11)), BB11)
                Store (DerefOf(Index(TEMP, 0x12)), BB12)
                Store (DerefOf(Index(TEMP, 0x13)), BB13)
                Store (DerefOf(Index(TEMP, 0x14)), BB14)
                Store (DerefOf(Index(TEMP, 0x15)), BB15)
                Store (DerefOf(Index(TEMP, 0x16)), BB16)
                Store (DerefOf(Index(TEMP, 0x17)), BB17)
                Store (DerefOf(Index(TEMP, 0x18)), BB18)
                Store (DerefOf(Index(TEMP, 0x19)), BB19)
                Store (DerefOf(Index(TEMP, 0x1A)), BB1A)
                Store (DerefOf(Index(TEMP, 0x1B)), BB1B)
                Store (DerefOf(Index(TEMP, 0x1C)), BB1C)
                Store (DerefOf(Index(TEMP, 0x1D)), BB1D)
                Store (DerefOf(Index(TEMP, 0x1E)), BB1E)
                Store (DerefOf(Index(TEMP, 0x1F)), BB1F)
            }

	    Scope (\_SB.PCI0.BAT0) {
            External(NBIX, PkgObj)
            External(PBIF, PkgObj)
            External(BIXT, PkgObj)
            External(_BIF, MethodObj)
            External(PBST, PkgObj)
            External(PUNT, IntObj)
            External(LFCC, IntObj)
            
            External(BLLO, IntObj) // Billow Observatory
            
	    	        // Override _BIX
	                Method (_BIX, 0, NotSerialized)  // _BIX: Battery Information Extended
            {
                If (LNot (^^LPCB.EC0.BATP (Zero)))
                {
                    Return (NBIX)
                }

                If (LEqual (^^LPCB.EC0.GBTT (Zero), 0xFF))
                {
                    Return (NBIX)
                }

                _BIF ()
                Store (DerefOf (Index (PBIF, Zero)), Index (BIXT, One))
                Store (DerefOf (Index (PBIF, One)), Index (BIXT, 0x02))
                Store (DerefOf (Index (PBIF, 0x02)), Index (BIXT, 0x03))
                Store (DerefOf (Index (PBIF, 0x03)), Index (BIXT, 0x04))
                Store (DerefOf (Index (PBIF, 0x04)), Index (BIXT, 0x05))
                Store (DerefOf (Index (PBIF, 0x05)), Index (BIXT, 0x06))
                Store (DerefOf (Index (PBIF, 0x06)), Index (BIXT, 0x07))
                Store (DerefOf (Index (PBIF, 0x07)), Index (BIXT, 0x0E))
                Store (DerefOf (Index (PBIF, 0x08)), Index (BIXT, 0x0F))
                Store (DerefOf (Index (PBIF, 0x09)), Index (BIXT, 0x10))
                Store (DerefOf (Index (PBIF, 0x0A)), Index (BIXT, 0x11))
                Store (DerefOf (Index (PBIF, 0x0B)), Index (BIXT, 0x12))
                Store (DerefOf (Index (PBIF, 0x0C)), Index (BIXT, 0x13))
                If (LEqual (DerefOf (Index (BIXT, One)), One))
                {
                    Store (Zero, Index (BIXT, One))
                    Store (DerefOf (Index (BIXT, 0x05)), Local0)
                    Multiply (DerefOf (Index (BIXT, 0x02)), Local0, Index (BIXT, 0x02))
                    Multiply (DerefOf (Index (BIXT, 0x03)), Local0, Index (BIXT, 0x03))
                    Multiply (DerefOf (Index (BIXT, 0x06)), Local0, Index (BIXT, 0x06))
                    Multiply (DerefOf (Index (BIXT, 0x07)), Local0, Index (BIXT, 0x07))
                    Multiply (DerefOf (Index (BIXT, 0x0E)), Local0, Index (BIXT, 0x0E))
                    Multiply (DerefOf (Index (BIXT, 0x0F)), Local0, Index (BIXT, 0x0F))
                    Divide (DerefOf (Index (BIXT, 0x02)), 0x03E8, Local0, Index (BIXT, 0x02))
                    Divide (DerefOf (Index (BIXT, 0x03)), 0x03E8, Local0, Index (BIXT, 0x03))
                    Divide (DerefOf (Index (BIXT, 0x06)), 0x03E8, Local0, Index (BIXT, 0x06))
                    Divide (DerefOf (Index (BIXT, 0x07)), 0x03E8, Local0, Index (BIXT, 0x07))
                    Divide (DerefOf (Index (BIXT, 0x0E)), 0x03E8, Local0, Index (BIXT, 0x0E))
                    Divide (DerefOf (Index (BIXT, 0x0F)), 0x03E8, Local0, Index (BIXT, 0x0F))
                }

                Store (B1B2(^^LPCB.EC0.XC30,^^LPCB.EC0.XC31), Index (BIXT, 0x08))
                Store (0x0001869F, Index (BIXT, 0x09))
                Return (BIXT)
            }

	    // Override FBST
            Method (FBST, 4, NotSerialized)
            {
                And (Arg1, 0xFFFF, Local1)
                Store (Zero, Local0)
                If (^^LPCB.EC0.ACAP ())
                {
                    Store (One, Local0)
                }

                If (Local0)
                {
                    If (CHGS (Zero))
{
    Store (0x02, Local0)
}
Else
{
    Store (Zero, Local0)
}
                }
                Else
                {
                    Store (One, Local0)
                }

                If (BLLO)
                {
                    ShiftLeft (One, 0x02, Local2)
                    Or (Local0, Local2, Local0)
                }

                If (And (^^LPCB.EC0.EB0S, 0x08))
                {
                    ShiftLeft (One, 0x02, Local2)
                    Or (Local0, Local2, Local0)
                }

                If (LGreaterEqual (Local1, 0x8000))
                {
                    Subtract (0xFFFF, Local1, Local1)
                }

                Store (Arg2, Local2)
                If (LEqual (PUNT, Zero))
                {
                    Multiply (Local1, ^^LPCB.EC0.B0DV, Local1)
                    Multiply (Local2, 0x0A, Local2)
                }

                And (Local0, 0x02, Local3)
                If (LNot (Local3))
                {
                    Subtract (LFCC, Local2, Local3)
                    Divide (LFCC, 0xC8, Local4, Local5)
                    If (LLess (Local3, Local5))
                    {
                        Store (LFCC, Local2)
                    }
                }
                Else
                {
                    Divide (LFCC, 0xC8, Local4, Local5)
                    Subtract (LFCC, Local5, Local4)
                    If (LGreater (Local2, Local4))
                    {
                        Store (Local4, Local2)
                    }
                }

                If (LNot (^^LPCB.EC0.ACAP ()))
                {
                    Divide (Local2, MBLF, Local3, Local4)
                    If (LLess (Local1, Local4))
                    {
                        Store (Local4, Local1)
                    }
                }

                Store (Local0, Index (PBST, Zero))
                Store (Local1, Index (PBST, One))
                Store (Local2, Index (PBST, 0x02))
                Store (Arg3, Index (PBST, 0x03))
            }
	    }
}
}
