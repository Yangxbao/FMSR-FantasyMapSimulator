
void BrushManager__DrawShapes(longlong param_1,undefined8 param_2)

{
  undefined8 uVar1;
  undefined8 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  char cVar5;
  longlong lVar6;
  undefined4 *puVar7;
  undefined8 *puVar8;
  undefined4 uVar9;
  undefined4 uVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  undefined4 uVar13;
  longlong local_res20;
  undefined8 local_108;
  undefined4 local_100;
  undefined4 local_fc;
  undefined8 local_f8;
  undefined4 local_f0;
  undefined8 local_e8;
  longlong *local_e0;
  undefined8 local_c8;
  undefined8 uStack_c0;
  undefined8 local_b8;
  undefined8 uStack_b0;
  undefined8 local_a8;
  undefined8 uStack_a0;
  undefined8 local_98;
  undefined8 uStack_90;
  
  if (DAT_1830601fa == '\0') {
    FUN_1802334a0(&DAT_182ec3eb0);
    FUN_1802334a0(&DAT_182ee2ed8);
    DAT_1830601fa = '\x01';
  }
  cVar5 = BrushManager__IsEnableBrush(param_1,0);
  if (cVar5 != '\0') {
    if (*(int *)(DAT_182ec3eb0 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    local_res20 = Shapes_Draw__Command(param_2,0x12,0);
    local_e8 = 0;
    local_e0 = &local_res20;
    if (DAT_183060203 == '\0') {
      FUN_1802334a0(&DAT_182ec62f8);
      DAT_183060203 = '\x01';
    }
    lVar6 = PlayerController__get_Instance(0);
    if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    if (*(int *)(lVar6 + 0x90) == 8) {
      if (*(int *)(DAT_182ec62f8 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      lVar6 = EditPanelUI__get_Instance(0);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(longlong *)(lVar6 + 0x128) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar11 = SliderValueConnector__get_Value(*(longlong *)(lVar6 + 0x128),0);
      puVar7 = (undefined4 *)BrushManager__GetColorFromHeight(&local_108,param_1,uVar11,0);
      uVar11 = *puVar7;
      uVar13 = puVar7[1];
      uVar12 = puVar7[2];
    }
    else {
      uVar11 = 0x3f800000;
      uVar13 = 0;
      uVar12 = 0;
    }
    uVar10 = 0;
    if (DAT_1830601fe == '\0') {
      FUN_1802334a0(&DAT_182e8e658);
      DAT_1830601fe = '\x01';
    }
    lVar6 = BrushManager__GetCurrentBrushRadiusSlider(param_1,0);
    if (*(int *)(DAT_182e8e658 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    cVar5 = UnityEngine_Object__op_Inequality(lVar6,0,0);
    if (cVar5 == '\0') {
      lVar6 = PlayerController__get_Instance(0);
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if ((*(int *)(lVar6 + 0x90) == 0x18) || (*(int *)(lVar6 + 0x90) == 0x19)) {
        uVar10 = 0x40a00000;
      }
    }
    else {
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      uVar10 = SliderValueConnector__get_Value(lVar6,0);
    }
    uVar9 = BrushManager__GetCurrentBrushThickness(param_1,0);
    uVar1 = *(undefined8 *)(param_1 + 0x24);
    uVar3 = *(undefined4 *)(param_1 + 0x2c);
    if (DAT_18306025b == '\0') {
      FUN_1802334a0(&DAT_182edbda8);
      DAT_18306025b = '\x01';
    }
    uVar2 = *(undefined8 *)(*(longlong *)(DAT_182edbda8 + 0xb8) + 0x54);
    uVar4 = *(undefined4 *)(*(longlong *)(DAT_182edbda8 + 0xb8) + 0x5c);
    local_108 = CONCAT44(uVar13,uVar11);
    local_fc = 0x3f800000;
    local_100 = uVar12;
    puVar8 = (undefined8 *)Shapes_DiscColors__op_Implicit(&local_c8,&local_108,0);
    local_c8 = *puVar8;
    uStack_c0 = puVar8[1];
    local_b8 = puVar8[2];
    uStack_b0 = puVar8[3];
    local_a8 = puVar8[4];
    uStack_a0 = puVar8[5];
    local_98 = puVar8[6];
    uStack_90 = puVar8[7];
    if (*(int *)(DAT_182ec3eb0 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    local_108 = uVar1;
    local_100 = uVar3;
    local_f8 = uVar2;
    local_f0 = uVar4;
    FUN_18047c1e0(&local_108,&local_f8,uVar10,uVar9,&local_c8,0);
    if (local_res20 != 0) {
      FUN_180002f00(0,DAT_182ee2ed8);
    }
  }
  return;
}

