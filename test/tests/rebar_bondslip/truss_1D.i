[Mesh]
    [line]
      type = GeneratedMeshGenerator
      dim = 1
      xmin = 0
      xmax = 1
      nx = 100
      boundary_name_prefix = line
      boundary_id_offset = 10
    []
    [line_id]
      type = SubdomainIDGenerator
      input = line
      subdomain_id = 2
    []
    [blcok_rename]
      type = RenameBlockGenerator
      input = line_id
      old_block = '2'
      new_block = 'line'
    []
  []
  
  [GlobalParams]
    displacements = 'disp_x disp_y'
  []

  
  [Variables]
    [disp_x]
    []
    [disp_y]
    []
  []
  
  [AuxVariables]
    [./axial_stress]
        order = CONSTANT
        family = MONOMIAL
      [../]
      [./e_over_l]
        order = CONSTANT
        family = MONOMIAL
      [../]
      [./area]
        order = CONSTANT
        family = MONOMIAL
      [../]
      [./react_x]
        order = FIRST
        family = LAGRANGE
      [../]
      [./react_y]
        order = FIRST
        family = LAGRANGE
      [../]
      [./react_z]
        order = FIRST
        family = LAGRANGE
      [../]
  []


  [Physics/SolidMechanics/LineElement/QuasiStatic] #this is deprecated and need to be updated
    [Reinforcement_block]
    block = 'line'
    truss = true
    area = area
    displacements = 'disp_x disp_y'
    save_in = 'react_x react_y'
    []
  []
  
  [AuxKernels]
    [./axial_stress]
      type = MaterialRealAux
      block = 'line'
      property = axial_stress
      variable = axial_stress
    [../]
    [./e_over_l]
      type = MaterialRealAux
      block = 'line'
      property = e_over_l
      variable = e_over_l
    [../]
    [./area]
      type = ConstantAux
      block = 'line'
      variable = area
      value = 0.8
      execute_on = 'initial timestep_begin'
    [../]
  []

  
  [Materials]
    [truss]
      type = LinearElasticTruss
      block = 'line'
      youngs_modulus = 2e11
      #why the displacements param is not specified (it is shown in the code as a required param)
    []
  []
  

  [BCs]
    [loading]
      type = FunctionDirichletBC
      variable = disp_x
      boundary = 'line_right'
      
      function = 1
      preset = true
    []

    [loading2]
      type = DirichletBC
      variable = disp_x
      boundary = 'line_left'    
      value = 0
    []
  []
  
  [Preconditioning]
    [./SMP]
      type = SMP
      full = true
    [../]
  []
  
  [Executioner]
    type = Transient
  
    solve_type = PJFNK
  
    petsc_options_iname = '-pc_type -ksp_gmres_restart'
    petsc_options_value = 'jacobi   101'
  
    nl_max_its = 15
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-10
  
    dt = 1
    num_steps = 1
    end_time = 1
  []
  
  
  [Outputs]
    exodus = true
    # csv = true
  []
  