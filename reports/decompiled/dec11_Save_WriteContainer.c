
void SaveSystem__WriteBinarySaveContainer(undefined8 param_1,undefined8 param_2)

{
  undefined8 uVar1;
  longlong *plVar2;
  undefined8 uVar3;
  longlong *plVar4;
  longlong lVar5;
  longlong lVar6;
  longlong *local_res20;
  ulonglong in_stack_fffffffffffffe78;
  ulonglong uVar7;
  undefined8 in_stack_fffffffffffffe80;
  undefined4 uVar8;
  longlong *local_168;
  longlong *local_160;
  longlong *local_158;
  longlong *local_150;
  longlong local_148;
  longlong *local_140;
  longlong local_138;
  longlong local_130;
  longlong local_128;
  longlong *local_120;
  undefined8 local_118;
  longlong **local_110;
  undefined8 local_108;
  longlong **local_100;
  undefined8 local_f8;
  longlong **local_f0;
  undefined8 local_e8;
  longlong *local_e0;
  undefined8 local_d8;
  longlong **local_d0;
  undefined8 local_c8;
  undefined8 local_b8;
  longlong *local_b0;
  undefined8 local_a8;
  longlong *local_a0;
  undefined8 local_98;
  longlong *local_90;
  
  uVar8 = (undefined4)((ulonglong)in_stack_fffffffffffffe80 >> 0x20);
  if (DAT_183060311 == '\0') {
    FUN_1802334a0(&DAT_182e94ff0);
    FUN_1802334a0(&DAT_182ea0cc0);
    FUN_1802334a0(&DAT_182e7fc98);
    FUN_1802334a0(&DAT_182ec9038);
    FUN_1802334a0(&DAT_182eb3500);
    FUN_1802334a0(&DAT_182ed1158);
    FUN_1802334a0(&DAT_182ed5818);
    FUN_1802334a0(&DAT_182ee2ed8);
    FUN_1802334a0(&DAT_182ead748);
    FUN_1802334a0(&DAT_182ebe080);
    FUN_1802334a0(&DAT_182ed4a10);
    FUN_1802334a0(&DAT_182ef4498);
    DAT_183060311 = '\x01';
  }
  local_168 = (longlong *)0x0;
  local_160 = (longlong *)0x0;
  local_128 = 0;
  local_130 = 0;
  local_138 = 0;
  local_148 = 0;
  local_150 = (longlong *)0x0;
  local_158 = (longlong *)0x0;
  uVar1 = FUN_180232fe0(DAT_182e7fc98,0x10);
  local_e8 = uVar1;
  local_120 = (longlong *)System_Security_Cryptography_RandomNumberGenerator__Create(0);
  local_d8 = 0;
  local_d0 = &local_120;
  if (local_120 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  (**(code **)(*local_120 + 0x198))(local_120,uVar1,*(undefined8 *)(*local_120 + 0x1a0));
  if (local_120 != (longlong *)0x0) {
    FUN_180002f00(0,DAT_182ee2ed8);
  }
  plVar2 = (longlong *)thunk_FUN_1802a5470(DAT_182ed1158);
  if (plVar2 != (longlong *)0x0) {
    local_d8 = 0;
    local_c8 = 0;
    System_IO_FileStream___ctor
              (plVar2,param_1,1,2,in_stack_fffffffffffffe78 & 0xffffffff00000000,
               CONCAT44(uVar8,0x20000),0x8000000,0);
    local_f8 = 0;
    local_f0 = &local_140;
    local_140 = plVar2;
    uVar3 = System_Text_Encoding__get_UTF8(0);
    plVar4 = (longlong *)thunk_FUN_1802a5470(DAT_182ea0cc0);
    if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    System_IO_BinaryWriter___ctor(plVar4,plVar2,uVar3,1,0);
    local_118 = 0;
    local_110 = &local_168;
    local_168 = plVar4;
    if (*(int *)(DAT_182ead748 + 0xe0) == 0) {
      il2cpp_runtime_class_init(DAT_182ead748);
    }
    if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*plVar4 + 0x1e8))
              (plVar4,*(undefined8 *)(*(longlong *)(DAT_182ead748 + 0xb8) + 8),
               *(undefined8 *)(*plVar4 + 0x1f0));
    if (local_168 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*local_168 + 600))(local_168,1,*(undefined8 *)(*local_168 + 0x260));
    if (local_140 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    local_d8 = (**(code **)(*local_140 + 0x1f8))(local_140,*(undefined8 *)(*local_140 + 0x200));
    if (local_168 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*local_168 + 0x278))(local_168,0,*(undefined8 *)(*local_168 + 0x280));
    if (local_168 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*local_168 + 0x1e8))(local_168,uVar1,*(undefined8 *)(*local_168 + 0x1f0));
    if (local_168 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*local_168 + 0x1a8))(local_168,*(undefined8 *)(*local_168 + 0x1b0));
    if (local_168 != (longlong *)0x0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
    if (*(int *)(DAT_182e94ff0 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    plVar2 = (longlong *)System_Security_Cryptography_Aes__Create(0);
    local_108 = 0;
    local_100 = &local_160;
    local_160 = plVar2;
    plVar4 = (longlong *)System_Text_Encoding__get_UTF8(0);
    if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    uVar3 = (**(code **)(*plVar4 + 0x268))(plVar4,DAT_182ef4498,*(undefined8 *)(*plVar4 + 0x270));
    if (plVar2 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*plVar2 + 0x1f8))(plVar2,uVar3,*(undefined8 *)(*plVar2 + 0x200));
    if (local_160 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*local_160 + 0x1d8))(local_160,uVar1,*(undefined8 *)(*local_160 + 0x1e0));
    plVar2 = local_160;
    if (local_160 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    uVar1 = (**(code **)(*local_160 + 0x1e8))(local_160,*(undefined8 *)(*local_160 + 0x1f0));
    if (local_160 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    uVar3 = (**(code **)(*local_160 + 0x1c8))(local_160,*(undefined8 *)(*local_160 + 0x1d0));
    lVar5 = *plVar2;
    lVar5 = (**(code **)(lVar5 + 0x288))(plVar2,uVar1,uVar3,*(undefined8 *)(lVar5 + 0x290));
    plVar2 = local_140;
    local_98 = 0;
    local_90 = &local_128;
    local_128 = lVar5;
    lVar6 = thunk_FUN_1802a5470(DAT_182eb3500);
    if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    System_Security_Cryptography_CryptoStream___ctor(lVar6,plVar2,lVar5,1,0);
    local_a8 = 0;
    local_a0 = &local_130;
    local_130 = lVar6;
    lVar5 = thunk_FUN_1802a5470(DAT_182ed5818);
    if (lVar5 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    uVar1 = 0;
    System_IO_Compression_GZipStream___ctor(lVar5,lVar6,0,1,0);
    local_b8 = 0;
    local_b0 = &local_138;
    local_138 = lVar5;
    lVar6 = thunk_FUN_1802a5470(DAT_182ec9038);
    if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    SaveSystem_CountingStream___ctor(lVar6,lVar5,1,0);
    local_e8 = 0;
    local_e0 = &local_148;
    local_148 = lVar6;
    lVar5 = thunk_FUN_1802a5470(DAT_182ed4a10);
    if (lVar5 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    System_Text_UTF8Encoding___ctor(lVar5,0,1,0);
    plVar2 = (longlong *)thunk_FUN_1802a5470(DAT_182ebe080);
    if (plVar2 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    uVar8 = 0;
    uVar7 = CONCAT71((int7)((ulonglong)uVar1 >> 8),1);
    System_IO_StreamWriter___ctor(plVar2,lVar6,lVar5,0x20000,uVar7,0);
    local_118 = 0;
    local_110 = &local_150;
    local_150 = plVar2;
    if (*(int *)(DAT_182ead748 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    SaveSystem__WriteRootV2(plVar2,param_2,0);
    if (local_150 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    (**(code **)(*local_150 + 0x1d8))(local_150,*(undefined8 *)(*local_150 + 0x1e0));
    if (local_148 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    uVar1 = *(undefined8 *)(local_148 + 0x40);
    local_c8 = uVar1;
    if (local_150 != (longlong *)0x0) {
      FUN_180002f00(0,DAT_182ee2ed8,local_150);
    }
    if (local_148 != 0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
    if (local_138 != 0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
    if (local_130 != 0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
    if (local_128 != 0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
    if (local_160 != (longlong *)0x0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
    if (local_140 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    System_Security_Cryptography_CryptoStream__Clear(local_140,0);
    plVar2 = (longlong *)thunk_FUN_1802a5470(DAT_182ed1158);
    if (plVar2 != (longlong *)0x0) {
      System_IO_FileStream___ctor
                (plVar2,param_1,3,2,uVar7 & 0xffffffff00000000,CONCAT44(uVar8,0x20000),0x10000000,0)
      ;
      local_108 = 0;
      local_100 = &local_res20;
      local_res20 = plVar2;
      uVar3 = System_Text_Encoding__get_UTF8(0);
      plVar4 = (longlong *)thunk_FUN_1802a5470(DAT_182ea0cc0);
      if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      System_IO_BinaryWriter___ctor(plVar4,plVar2,uVar3,1,0);
      local_f8 = 0;
      local_f0 = &local_158;
      local_158 = plVar4;
      if (local_res20 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      (**(code **)(*local_res20 + 0x208))
                (local_res20,local_d8,*(undefined8 *)(*local_res20 + 0x210));
      if (local_158 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      (**(code **)(*local_158 + 0x278))(local_158,uVar1,*(undefined8 *)(*local_158 + 0x280));
      if (local_158 != (longlong *)0x0) {
        (**(code **)(*local_158 + 0x1a8))(local_158,*(undefined8 *)(*local_158 + 0x1b0));
        if (local_res20 != (longlong *)0x0) {
          (**(code **)(*local_res20 + 0x3d8))(local_res20,1,*(undefined8 *)(*local_res20 + 0x3e0));
          if (local_158 != (longlong *)0x0) {
            FUN_180002f00(0,DAT_182ee2ed8);
          }
          if (local_res20 != (longlong *)0x0) {
            FUN_180002f00(0,DAT_182ee2ed8);
          }
          return;
        }
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

