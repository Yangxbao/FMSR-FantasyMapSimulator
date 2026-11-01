
void HeightMapGenerator__GenerateFromTemplate(undefined8 param_1,undefined4 param_2)

{
  uint uVar1;
  longlong *plVar2;
  undefined8 *puVar3;
  longlong lVar4;
  longlong lVar5;
  ushort uVar6;
  ulonglong uVar8;
  ulonglong uVar7;
  
  if (DAT_18305fb9b == '\0') {
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182edc260);
    FUN_1802334a0(&DAT_182ecdb10);
    FUN_1802334a0(&DAT_182e78160);
    FUN_1802334a0(&DAT_182e7c178);
    FUN_1802334a0(&DAT_182ebcd58);
    DAT_18305fb9b = '\x01';
  }
  if (*(int *)(DAT_182edc260 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  plVar2 = (longlong *)HeightmapTemplates__get_Templates(0);
  if (plVar2 != (longlong *)0x0) {
    lVar4 = *plVar2;
    uVar8 = 0;
    if (*(ushort *)(lVar4 + 0x12a) != 0) {
      uVar7 = uVar8;
      do {
        if (*(longlong *)(*(longlong *)(lVar4 + 0xb0) + uVar7 * 0x10) == DAT_182ecdb10) {
          puVar3 = (undefined8 *)
                   ((longlong)*(int *)(*(longlong *)(lVar4 + 0xb0) + 8 + uVar7 * 0x10) * 0x10 +
                    0x138 + lVar4);
          goto LAB_18038ba56;
        }
        uVar6 = (short)uVar7 + 1;
        uVar7 = (ulonglong)uVar6;
      } while (uVar6 < *(ushort *)(lVar4 + 0x12a));
    }
    puVar3 = (undefined8 *)FUN_180254000(plVar2,DAT_182ecdb10,0);
LAB_18038ba56:
    lVar4 = (*(code *)*puVar3)(plVar2,param_2,puVar3[1]);
    if (((lVar4 != 0) && (*(longlong *)(lVar4 + 0x18) != 0)) &&
       (lVar4 = System_String__Split(*(longlong *)(lVar4 + 0x18),DAT_182e78160,0,0), lVar4 != 0)) {
      do {
        uVar1 = (uint)uVar8;
        if (*(int *)(lVar4 + 0x18) <= (int)uVar1) {
          return;
        }
        if (*(uint *)(lVar4 + 0x18) <= uVar1) {
LAB_18038bbc1:
                    /* WARNING: Subroutine does not return */
          FUN_180233670();
        }
        lVar5 = *(longlong *)(lVar4 + 0x20 + (longlong)(int)uVar1 * 8);
        if (((lVar5 == 0) || (lVar5 = System_String__Trim(lVar5,0), lVar5 == 0)) ||
           (lVar5 = System_String__Split(lVar5,DAT_182e7c178,0,0), lVar5 == 0)) break;
        if (*(int *)(lVar5 + 0x18) < 2) {
          if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
            il2cpp_runtime_class_init();
          }
          UnityEngine_Debug__LogError(DAT_182ebcd58,0);
        }
        if ((((*(int *)(lVar5 + 0x18) == 0) || (*(uint *)(lVar5 + 0x18) < 2)) ||
            (((2 < (int)*(uint *)(lVar5 + 0x18) && (*(uint *)(lVar5 + 0x18) < 3)) ||
             ((3 < (int)*(uint *)(lVar5 + 0x18) && (*(uint *)(lVar5 + 0x18) < 4)))))) ||
           ((4 < (int)*(uint *)(lVar5 + 0x18) && (*(uint *)(lVar5 + 0x18) < 5))))
        goto LAB_18038bbc1;
        HeightMapGenerator__addStep(param_1);
        uVar8 = (ulonglong)(uVar1 + 1);
      } while( true );
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

