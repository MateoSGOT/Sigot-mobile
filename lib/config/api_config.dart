class ApiConfig {
  static const String baseUrl = 'https://sigot-api.onrender.com';
  static const Duration timeout = Duration(seconds: 60);

  static const String login = '/api/auth/login';
  static const String recuperarPassword = '/api/auth/recuperar-password';
  static const String agenda = '/api/agenda';
  static const String vehiculos = '/api/vehiculos';
  static const String ordenes = '/api/ordenes';
  static const String compras = '/api/compras';
  static const String clientes = '/api/clientes';
  static const String empleados = '/api/empleados';
  static const String novedades = '/api/novedades';
  static const String permisosRol = '/api/permisos/rol';

  // Dashboard / reportes (paridad con dashboardService.js de la web)
  static const String dashboardResumen = '/api/dashboard/resumen';
  static const String dashboardIngresos = '/api/dashboard/ingresos';
  static const String dashboardTopServicios = '/api/dashboard/top-servicios';
  static const String tiposDocumento = '/api/catalogos/tipos-documento';
  static const String marcas = '/api/catalogos/marcas';

  // Portal del cliente (paridad con PortalPage.jsx de la web)
  static const String portalVehiculos = '/api/portal/vehiculos';
  static const String portalOrdenes = '/api/portal/ordenes';
  static const String portalCitas = '/api/portal/citas';
  static const String portalPerfil = '/api/portal/perfil';
  static const String portalEmpleadosDisponibles =
      '/api/portal/empleados-disponibles';

  static const String tokenKey = 'sigot_token';
  static const String empleadoKey = 'sigot_empleado';
  static const String clienteKey = 'sigot_cliente';
  static const String tipoKey = 'sigot_tipo';
}
