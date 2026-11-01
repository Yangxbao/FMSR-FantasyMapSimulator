
undefined8 Puerts_DefaultLoader__ReadFile(longlong param_1,undefined8 param_2,longlong *param_3)

{
  char cVar1;
  undefined8 uVar2;
  longlong *plVar3;
  longlong lVar4;
  
  if (DAT_183064fa9 == '\0') {
    FUN_1802334a0(&DAT_182e8e658);
    FUN_1802334a0(&DAT_182e95788);
    FUN_1802334a0(&DAT_182ec6f18);
    FUN_1802334a0(&DAT_182ed6e90);
    FUN_1802334a0(&DAT_182ed0210);
    DAT_183064fa9 = '\x01';
  }
  uVar2 = Puerts_DefaultLoader__PathToUse(param_1,param_2,0);
  plVar3 = (longlong *)UnityEngine_Resources__Load(uVar2,0);
  if (plVar3 != (longlong *)0x0) {
    if ((*(byte *)(*plVar3 + 300) < *(byte *)(DAT_182ec6f18 + 300)) ||
       (*(longlong *)
         (*(longlong *)(*plVar3 + 200) + -8 + (ulonglong)*(byte *)(DAT_182ec6f18 + 300) * 8) !=
        DAT_182ec6f18)) {
                    /* WARNING: Subroutine does not return */
      FUN_180232fa0(plVar3);
    }
  }
  uVar2 = *(undefined8 *)(param_1 + 0x10);
  if (*(int *)(DAT_182e95788 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  lVar4 = System_IO_Path__Combine(uVar2,param_2,0);
  *param_3 = lVar4;
  FUN_180232f70(param_3,lVar4);
  if (*param_3 != 0) {
    lVar4 = System_String__Replace(*param_3,DAT_182ed0210,DAT_182ed6e90,0);
    *param_3 = lVar4;
    FUN_180232f70(param_3,lVar4);
    if (*(int *)(DAT_182e8e658 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    cVar1 = UnityEngine_Object__op_Equality(plVar3,0,0);
    if (cVar1 != '\0') {
      return 0;
    }
    if (plVar3 != (longlong *)0x0) {
      uVar2 = UnityEngine_TextAsset__get_text(plVar3,0);
      return uVar2;
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

