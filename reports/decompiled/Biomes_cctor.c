
void Biomes___cctor(void)

{
  longlong *plVar1;
  longlong lVar2;
  undefined8 uVar3;
  undefined8 local_18;
  undefined8 local_10;
  
  if (DAT_18305faf5 == '\0') {
    FUN_1802334a0(&DAT_182ea1000);
    FUN_1802334a0(&DAT_182e80508);
    FUN_1802334a0(&DAT_182e93110);
    FUN_1802334a0(&DAT_182e86100);
    FUN_1802334a0(&DAT_182e8a7c0);
    FUN_1802334a0(&DAT_182e8b880);
    FUN_1802334a0(&DAT_182ee2a58);
    FUN_1802334a0(&DAT_182ee2c00);
    FUN_1802334a0(&DAT_182ee3448);
    FUN_1802334a0(&DAT_182ee35f0);
    FUN_1802334a0(&DAT_182ee3c90);
    FUN_1802334a0(&DAT_182ee4328);
    FUN_1802334a0(&DAT_182ee49c8);
    FUN_1802334a0(&DAT_182eaf960);
    FUN_1802334a0(&DAT_182e95960);
    FUN_1802334a0(&DAT_182e9fd88);
    FUN_1802334a0(&DAT_182e77280);
    FUN_1802334a0(&DAT_182e9ba68);
    FUN_1802334a0(&DAT_182eeb370);
    FUN_1802334a0(&DAT_182ec1e48);
    FUN_1802334a0(&DAT_182e86018);
    FUN_1802334a0(&DAT_182eacfb8);
    FUN_1802334a0(&DAT_182eedb30);
    FUN_1802334a0(&DAT_182ec2e00);
    FUN_1802334a0(&DAT_182eeb2a0);
    FUN_1802334a0(&DAT_182e8c050);
    DAT_18305faf5 = '\x01';
  }
  plVar1 = (longlong *)FUN_180232fe0(DAT_182e8b880,0xd);
  if (plVar1 == (longlong *)0x0) {
LAB_180364969:
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if ((DAT_182e86018 != 0) &&
     (lVar2 = thunk_FUN_1802a41d0(DAT_182e86018,*(undefined8 *)(*plVar1 + 0x40)), lVar2 == 0)) {
    uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
    FUN_180233640(uVar3,0);
  }
  lVar2 = DAT_182e86018;
  if ((int)plVar1[3] != 0) {
    plVar1[4] = DAT_182e86018;
    FUN_180232f70(plVar1 + 4,lVar2);
    if ((DAT_182ec1e48 != 0) &&
       (lVar2 = thunk_FUN_1802a41d0(DAT_182ec1e48,*(undefined8 *)(*plVar1 + 0x40)), lVar2 == 0)) {
      uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
      FUN_180233640(uVar3,0);
    }
    lVar2 = DAT_182ec1e48;
    if (1 < *(uint *)(plVar1 + 3)) {
      plVar1[5] = DAT_182ec1e48;
      FUN_180232f70(plVar1 + 5,lVar2);
      if ((DAT_182ec2e00 != 0) &&
         (lVar2 = thunk_FUN_1802a41d0(DAT_182ec2e00,*(undefined8 *)(*plVar1 + 0x40)), lVar2 == 0)) {
        uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
        FUN_180233640(uVar3,0);
      }
      lVar2 = DAT_182ec2e00;
      if (2 < *(uint *)(plVar1 + 3)) {
        plVar1[6] = DAT_182ec2e00;
        FUN_180232f70(plVar1 + 6,lVar2);
        if ((DAT_182e77280 != 0) &&
           (lVar2 = thunk_FUN_1802a41d0(DAT_182e77280,*(undefined8 *)(*plVar1 + 0x40)), lVar2 == 0))
        {
          uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
          FUN_180233640(uVar3,0);
        }
        lVar2 = DAT_182e77280;
        if (3 < *(uint *)(plVar1 + 3)) {
          plVar1[7] = DAT_182e77280;
          FUN_180232f70(plVar1 + 7,lVar2);
          if ((DAT_182e9ba68 != 0) &&
             (lVar2 = thunk_FUN_1802a41d0(DAT_182e9ba68,*(undefined8 *)(*plVar1 + 0x40)), lVar2 == 0
             )) {
            uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
            FUN_180233640(uVar3,0);
          }
          lVar2 = DAT_182e9ba68;
          if (4 < *(uint *)(plVar1 + 3)) {
            plVar1[8] = DAT_182e9ba68;
            FUN_180232f70(plVar1 + 8,lVar2);
            if ((DAT_182eeb370 != 0) &&
               (lVar2 = thunk_FUN_1802a41d0(DAT_182eeb370,*(undefined8 *)(*plVar1 + 0x40)),
               lVar2 == 0)) {
              uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
              FUN_180233640(uVar3,0);
            }
            lVar2 = DAT_182eeb370;
            if (5 < *(uint *)(plVar1 + 3)) {
              plVar1[9] = DAT_182eeb370;
              FUN_180232f70(plVar1 + 9,lVar2);
              if ((DAT_182eaf960 != 0) &&
                 (lVar2 = thunk_FUN_1802a41d0(DAT_182eaf960,*(undefined8 *)(*plVar1 + 0x40)),
                 lVar2 == 0)) {
                uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                FUN_180233640(uVar3,0);
              }
              lVar2 = DAT_182eaf960;
              if (6 < *(uint *)(plVar1 + 3)) {
                plVar1[10] = DAT_182eaf960;
                FUN_180232f70(plVar1 + 10,lVar2);
                if ((DAT_182eeb2a0 != 0) &&
                   (lVar2 = thunk_FUN_1802a41d0(DAT_182eeb2a0,*(undefined8 *)(*plVar1 + 0x40)),
                   lVar2 == 0)) {
                  uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                  FUN_180233640(uVar3,0);
                }
                lVar2 = DAT_182eeb2a0;
                if (7 < *(uint *)(plVar1 + 3)) {
                  plVar1[0xb] = DAT_182eeb2a0;
                  FUN_180232f70(plVar1 + 0xb,lVar2);
                  if ((DAT_182e9fd88 != 0) &&
                     (lVar2 = thunk_FUN_1802a41d0(DAT_182e9fd88,*(undefined8 *)(*plVar1 + 0x40)),
                     lVar2 == 0)) {
                    uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                    FUN_180233640(uVar3,0);
                  }
                  lVar2 = DAT_182e9fd88;
                  if (8 < *(uint *)(plVar1 + 3)) {
                    plVar1[0xc] = DAT_182e9fd88;
                    FUN_180232f70(plVar1 + 0xc,lVar2);
                    if ((DAT_182eacfb8 != 0) &&
                       (lVar2 = thunk_FUN_1802a41d0(DAT_182eacfb8,*(undefined8 *)(*plVar1 + 0x40)),
                       lVar2 == 0)) {
                      uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                      FUN_180233640(uVar3,0);
                    }
                    lVar2 = DAT_182eacfb8;
                    if (9 < *(uint *)(plVar1 + 3)) {
                      plVar1[0xd] = DAT_182eacfb8;
                      FUN_180232f70(plVar1 + 0xd,lVar2);
                      if ((DAT_182eedb30 != 0) &&
                         (lVar2 = thunk_FUN_1802a41d0(DAT_182eedb30,*(undefined8 *)(*plVar1 + 0x40))
                         , lVar2 == 0)) {
                        uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                        FUN_180233640(uVar3,0);
                      }
                      lVar2 = DAT_182eedb30;
                      if (10 < *(uint *)(plVar1 + 3)) {
                        plVar1[0xe] = DAT_182eedb30;
                        FUN_180232f70(plVar1 + 0xe,lVar2);
                        if ((DAT_182e8c050 != 0) &&
                           (lVar2 = thunk_FUN_1802a41d0(DAT_182e8c050,
                                                        *(undefined8 *)(*plVar1 + 0x40)), lVar2 == 0
                           )) {
                          uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                          FUN_180233640(uVar3,0);
                        }
                        lVar2 = DAT_182e8c050;
                        if (0xb < *(uint *)(plVar1 + 3)) {
                          plVar1[0xf] = DAT_182e8c050;
                          FUN_180232f70(plVar1 + 0xf,lVar2);
                          if ((DAT_182e95960 != 0) &&
                             (lVar2 = thunk_FUN_1802a41d0(DAT_182e95960,
                                                          *(undefined8 *)(*plVar1 + 0x40)),
                             lVar2 == 0)) {
                            uVar3 = thunk_FUN_180205420();
                    /* WARNING: Subroutine does not return */
                            FUN_180233640(uVar3,0);
                          }
                          lVar2 = DAT_182e95960;
                          if (0xc < *(uint *)(plVar1 + 3)) {
                            plVar1[0x10] = DAT_182e95960;
                            FUN_180232f70(plVar1 + 0x10,lVar2);
                            **(undefined8 **)(DAT_182ea1000 + 0xb8) = plVar1;
                            FUN_180232f70(*(undefined8 *)(DAT_182ea1000 + 0xb8),plVar1);
                            lVar2 = FUN_180232fe0(DAT_182e80508,0xd);
                            if (lVar2 == 0) goto LAB_180364969;
                            if (*(int *)(lVar2 + 0x18) != 0) {
                              *(undefined4 *)(lVar2 + 0x20) = 0x3e70f0f1;
                              *(undefined4 *)(lVar2 + 0x24) = 0x3f028283;
                              *(undefined4 *)(lVar2 + 0x28) = 0x3f52d2d3;
                              *(undefined4 *)(lVar2 + 0x2c) = 0x3f800000;
                              if (1 < *(uint *)(lVar2 + 0x18)) {
                                *(undefined4 *)(lVar2 + 0x30) = 0x3f800000;
                                *(undefined8 *)(lVar2 + 0x34) = 0x3f4ccccd;
                                *(undefined4 *)(lVar2 + 0x3c) = 0x3f800000;
                                if (2 < *(uint *)(lVar2 + 0x18)) {
                                  *(undefined4 *)(lVar2 + 0x40) = 0x3f800000;
                                  *(undefined4 *)(lVar2 + 0x44) = 0x3f66e6e7;
                                  *(undefined4 *)(lVar2 + 0x48) = 0x3f0c8c8d;
                                  *(undefined4 *)(lVar2 + 0x4c) = 0x3f800000;
                                  if (3 < *(uint *)(lVar2 + 0x18)) {
                                    *(undefined4 *)(lVar2 + 0x50) = 0x3f66e6e7;
                                    *(undefined4 *)(lVar2 + 0x54) = 0x3f5cdcdd;
                                    *(undefined4 *)(lVar2 + 0x58) = 0x3edcdcdd;
                                    *(undefined4 *)(lVar2 + 0x5c) = 0x3f800000;
                                    if (4 < *(uint *)(lVar2 + 0x18)) {
                                      *(undefined4 *)(lVar2 + 0x60) = 0x3f2aaaab;
                                      *(undefined4 *)(lVar2 + 100) = 0x3f66e6e7;
                                      *(undefined4 *)(lVar2 + 0x68) = 0x3ec8c8c9;
                                      *(undefined4 *)(lVar2 + 0x6c) = 0x3f800000;
                                      if (5 < *(uint *)(lVar2 + 0x18)) {
                                        *(undefined4 *)(lVar2 + 0x70) = 0x3f169697;
                                        *(undefined4 *)(lVar2 + 0x74) = 0x3f66e6e7;
                                        *(undefined4 *)(lVar2 + 0x78) = 0x3e8c8c8d;
                                        *(undefined4 *)(lVar2 + 0x7c) = 0x3f800000;
                                        if (6 < *(uint *)(lVar2 + 0x18)) {
                                          *(undefined4 *)(lVar2 + 0x80) = 0x3df0f0f1;
                                          *(undefined4 *)(lVar2 + 0x84) = 0x3f48c8c9;
                                          *(undefined4 *)(lVar2 + 0x88) = 0x3ea0a0a1;
                                          *(undefined4 *)(lVar2 + 0x8c) = 0x3f800000;
                                          if (7 < *(uint *)(lVar2 + 0x18)) {
                                            *(undefined4 *)(lVar2 + 0x90) = 0x3ea0a0a1;
                                            *(undefined4 *)(lVar2 + 0x94) = 0x3f5cdcdd;
                                            *(undefined4 *)(lVar2 + 0x98) = 0x3df0f0f1;
                                            *(undefined4 *)(lVar2 + 0x9c) = 0x3f800000;
                                            if (8 < *(uint *)(lVar2 + 0x18)) {
                                              *(undefined4 *)(lVar2 + 0xa0) = 0x3e48c8c9;
                                              *(undefined4 *)(lVar2 + 0xa4) = 0x3f3ebebf;
                                              *(undefined4 *)(lVar2 + 0xa8) = 0x3e8c8c8d;
                                              *(undefined4 *)(lVar2 + 0xac) = 0x3f800000;
                                              if (9 < *(uint *)(lVar2 + 0x18)) {
                                                *(undefined4 *)(lVar2 + 0xb0) = 0x3eb4b4b5;
                                                *(undefined4 *)(lVar2 + 0xb4) = 0x3f0c8c8d;
                                                *(undefined4 *)(lVar2 + 0xb8) = 0x3e70f0f1;
                                                *(undefined4 *)(lVar2 + 0xbc) = 0x3f800000;
                                                if (10 < *(uint *)(lVar2 + 0x18)) {
                                                  *(undefined4 *)(lVar2 + 0xc0) = 0x3f34b4b5;
                                                  *(undefined4 *)(lVar2 + 0xc4) = 0x3f20a0a1;
                                                  *(undefined4 *)(lVar2 + 200) = 0x3ec8c8c9;
                                                  *(undefined4 *)(lVar2 + 0xcc) = 0x3f800000;
                                                  if (0xb < *(uint *)(lVar2 + 0x18)) {
                                                    *(undefined4 *)(lVar2 + 0xd0) = 0x3f5cdcdd;
                                                    *(undefined4 *)(lVar2 + 0xd4) = 0x3f70f0f1;
                                                    *(undefined4 *)(lVar2 + 0xd8) = 0x3f800000;
                                                    *(undefined4 *)(lVar2 + 0xdc) = 0x3f800000;
                                                    if (0xc < *(uint *)(lVar2 + 0x18)) {
                                                      *(undefined4 *)(lVar2 + 0xe0) = 0x3da0a0a1;
                                                      *(undefined4 *)(lVar2 + 0xe4) = 0x3f34b4b5;
                                                      *(undefined4 *)(lVar2 + 0xe8) = 0x3e8c8c8d;
                                                      *(undefined4 *)(lVar2 + 0xec) = 0x3f800000;
                                                      *(longlong *)
                                                       (*(longlong *)(DAT_182ea1000 + 0xb8) + 8) =
                                                           lVar2;
                                                      FUN_180232f70(*(longlong *)
                                                                     (DAT_182ea1000 + 0xb8) + 8);
                                                      local_18 = 5;
                                                      local_10 = 0x1a;
                                                      uVar3 = FUN_180232f60(DAT_182e93110,&local_18)
                                                      ;
                                                                                                            
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee35f0,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x10) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x10,uVar3);
                                                  uVar3 = FUN_180232fe0(DAT_182e86100,0xd);
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee49c8,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x18) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x18,uVar3);
                                                  uVar3 = FUN_180232fe0(DAT_182e86100,0xd);
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee3c90,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x20) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x20,uVar3);
                                                  uVar3 = FUN_180232fe0(DAT_182e86100,0xd);
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee3448,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x28) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x28,uVar3);
                                                  uVar3 = FUN_180232fe0(DAT_182e8a7c0,0xd);
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee4328,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x30) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x30,uVar3);
                                                  uVar3 = FUN_180232fe0(DAT_182e8a7c0,0xd);
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee2a58,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x38) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x38,uVar3);
                                                  uVar3 = FUN_180232fe0(DAT_182e8a7c0,0xd);
                                                  System_Runtime_CompilerServices_RuntimeHelpers__InitializeArray
                                                            (uVar3,DAT_182ee2c00,0);
                                                  *(undefined8 *)
                                                   (*(longlong *)(DAT_182ea1000 + 0xb8) + 0x40) =
                                                       uVar3;
                                                  FUN_180232f70(*(longlong *)(DAT_182ea1000 + 0xb8)
                                                                + 0x40,uVar3);
                                                  lVar2 = *(longlong *)(DAT_182ea1000 + 0xb8);
                                                  *(undefined4 *)(lVar2 + 0x48) = 0x3d20a0a1;
                                                  *(undefined4 *)(lVar2 + 0x4c) = 0x3ef2f2f3;
                                                  *(undefined4 *)(lVar2 + 0x50) = 0x3f45c5c6;
                                                  *(undefined4 *)(lVar2 + 0x54) = 0x3f800000;
                                                  lVar2 = *(longlong *)(DAT_182ea1000 + 0xb8);
                                                  *(undefined4 *)(lVar2 + 0x58) = 0x3ec4c4c5;
                                                  *(undefined4 *)(lVar2 + 0x5c) = 0x3f038384;
                                                  *(undefined4 *)(lVar2 + 0x60) = 0x3f31b1b2;
                                                  *(undefined4 *)(lVar2 + 100) = 0x3f800000;
                                                  return;
                                                  }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233670();
}

