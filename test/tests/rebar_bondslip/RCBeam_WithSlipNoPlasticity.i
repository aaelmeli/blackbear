[Mesh]
    parallel_type = 'replicated'
    [rectangle]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 10
      ny = 10
      xmin = -0.5
      xmax = 0.5
      ymin = -0.5
      ymax = 0.5
      boundary_name_prefix = rectangle
    []
    [rectangle_id]
      type = SubdomainIDGenerator
      input = rectangle
      subdomain_id = 1
    []
    [line]
      type = GeneratedMeshGenerator
      dim = 1
      xmin = -0.5
      xmax = 0.5
      nx = 10
      boundary_name_prefix = line
      boundary_id_offset = 10
    []
    [line_id]
      type = SubdomainIDGenerator
      input = line
      subdomain_id = 2
    []
    [combined]
      type = MeshCollectionGenerator
      inputs = 'rectangle_id line_id'
    []
    [blcok_rename]
      type = RenameBlockGenerator
      input = combined
      old_block = '1 2'
      new_block = 'rectangle line'
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
      value = 2.00e-4
      execute_on = 'initial timestep_begin'
    [../]
  []
  [Physics/SolidMechanics/QuasiStatic]
    [Concrete_block]
      block = 'rectangle'
      strain = finite
      incremental = true
      generate_output = 'stress_xx stress_xy stress_yy strain_xx strain_xy strain_yy
                         vonmises_stress elastic_strain_xx elastic_strain_xy elastic_strain_yy'
      save_in = 'react_x react_y'
    []
  []

  [Physics/SolidMechanics/LineElement/QuasiStatic] 
    [Reinforcement_block]
    block = 'line'
    truss = true
    area = area
    displacements = 'disp_x disp_y'
    save_in = 'react_x react_y'
    []
  []
  
  [Constraints]
    # [equalvalue_dispx]
    #   type = EqualValueEmbeddedConstraint
    #   secondary = 'line'
    #   primary = 'rectangle'
    #   penalty = 1e10
    #   formulation = kinematic
    #   primary_variable = disp_x
    #   variable = disp_x
    # []

    # [equalvalue_dispy]
    #     type = EqualValueEmbeddedConstraint
    #   secondary = 'line'
    #   primary = 'rectangle'
    #     penalty = 1e10
    #     formulation = kinematic
    #     primary_variable = disp_y
    #     variable = disp_y
    #   []

      [rebar_x]
        type = RebarBondSlipConstraint
        secondary = 'line'
        primary = 'rectangle'
        penalty = 1e12
        variable = 'disp_x'
        primary_variable = 'disp_x'
        component = 0
        max_bondstress = 1e6
        transitional_slip_values = 0.001
        ultimate_slip = 0.1
        rebar_radius = 7.98e-3
      []
      [rebar_y]
        type = RebarBondSlipConstraint
        secondary = 'line'
        primary = 'rectangle'
        penalty = 1e12
        variable = 'disp_y'
        primary_variable = 'disp_y'
        component = 1
        max_bondstress = 10000 #how this should compare to the E_rebar
        transitional_slip_values = 0.001
        ultimate_slip = 0.1
        rebar_radius = 7.98e-3
      []  
  []


  [Materials]
    [Cijkl_concrete]
      type = ComputeIsotropicElasticityTensor
      youngs_modulus = 500e6
      poissons_ratio = 0.2
      block = 'rectangle'
    []

    [./stress]
      type = ComputeFiniteStrainElasticStress
      block = 'rectangle'
    [../]

    [truss]
      type = LinearElasticTruss
      block = 'line'
      youngs_modulus = 2e11
    []
  []
  

  [BCs]
    [loading]
      type = FunctionDirichletBC
      variable = disp_x
      boundary = 'rectangle_right'
      
      function = 0.1*t
      preset = true
    []

    [left_support_x]
      type = DirichletBC
      variable = disp_x
      boundary = 'rectangle_left'
      value = 0
    []
    [left_support_y]
      type = DirichletBC
      variable = disp_y
      boundary = 'rectangle_left'
      value = 0
    []
  []
  
  [Postprocessors]
    [./conc_disp_x]
      type = AverageNodalVariableValue
      variable = disp_x
      boundary = 'rectangle_right'
    [../]
    [./conc_disp_y]
      type = AverageNodalVariableValue
      variable = disp_y
      boundary = 'rectangle_right'
    [../]
    [./bar_disp_x]
      type = AverageNodalVariableValue
      variable = disp_x
      boundary = 'line_right'
    [../]
    [./bar_disp_y]
      type = AverageNodalVariableValue
      variable = disp_y
      boundary = 'line_right'
    [../]
    [./bar_fx]
      type = AverageNodalVariableValue
      variable = react_x
      boundary = 'line_left'
    [../]
    [./bar_fy]
      type = AverageNodalVariableValue
      variable = react_y
      boundary = 'line_left'
    [../]
    [./bar_disp_dx_left]
      type = AverageNodalVariableValue
      variable = disp_x
      boundary = 'line_left'
    [../]
    [./bar_disp_dy_left]
      type = AverageNodalVariableValue
      variable = disp_y
      boundary = 'line_left'
    [../]
    [./conc_fx]
      type = AverageNodalVariableValue
      variable = react_x
      boundary = 'rectangle_left'
    [../]

    [./conc_fy]
      type = AverageNodalVariableValue
      variable = react_y
      boundary = 'rectangle_left'
    [../]      
  
    [./conc_stress_xx]
      type = ElementAverageValue
      variable = stress_xx
      block = 'rectangle'
    [../]
    [./strain_xx]
      type = ElementAverageValue
      variable = strain_xx
      block = 'rectangle'
    [../]
    [./bar_stress_xx]
      type = ElementAverageValue
      variable = axial_stress
      block = 'line'
    [../]
  []

  [Preconditioning]
    [./SMP]
      type = SMP
      full = true
    [../]
  []
  [Executioner]
    type = Transient
  
    solve_type = FD
  
    petsc_options_iname = '-pc_type '
    petsc_options_value = 'lu '
  
    nl_max_its = 15
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-10
  
    dt = 0.001
    num_steps = 1000
    end_time = 1
  []
  
  [Outputs]
    exodus = true
    csv = true
  []
  