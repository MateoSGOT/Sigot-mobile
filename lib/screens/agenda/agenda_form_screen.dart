import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/auth_model.dart';
import '../../models/orden_model.dart';
import '../../models/vehiculo_model.dart';
import '../../providers/agenda_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vehiculo_provider.dart';

class AgendaFormScreen extends StatefulWidget {
  const AgendaFormScreen({super.key});

  @override
  State<AgendaFormScreen> createState() => _AgendaFormScreenState();
}

class _AgendaFormScreenState extends State<AgendaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();

  ClienteCatalogo? _cliente;
  VehiculoModel? _vehiculo;
  EmpleadoModel? _empleado;
  DateTime? _fecha;
  String? _hora;
  bool _loading = false;

  final List<String> _horariosBase = List.generate(
    21,
    (i) {
      final h = 8 + i ~/ 2;
      final m = (i % 2) * 30;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    },
  );

  /// Horarios disponibles para la fecha seleccionada: si es hoy, se excluyen
  /// las horas que ya pasaron.
  List<String> get _horarios {
    if (_fecha == null) return _horariosBase;
    final ahora = DateTime.now();
    final esHoy = _fecha!.year == ahora.year &&
        _fecha!.month == ahora.month &&
        _fecha!.day == ahora.day;
    if (!esHoy) return _horariosBase;
    return _horariosBase.where((h) {
      final p = h.split(':');
      final slot =
          DateTime(ahora.year, ahora.month, ahora.day, int.parse(p[0]), int.parse(p[1]));
      return slot.isAfter(ahora);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaProvider>().loadClientes();
      context.read<AgendaProvider>().loadEmpleados();
      context.read<VehiculoProvider>().load();
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  List<VehiculoModel> _vehiculosCliente(List<VehiculoModel> all) {
    if (_cliente == null) return [];
    return all
        .where((v) => v.cliente == _cliente!.nombre)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fecha == null) {
      _showError('Selecciona una fecha');
      return;
    }
    if (_hora == null) {
      _showError('Selecciona una hora');
      return;
    }
    setState(() => _loading = true);

    final empleado = _empleado ?? context.read<AuthProvider>().empleado!;
    final body = {
      'Id_Cliente': _cliente!.idCliente,
      'Id_Vehiculo': _vehiculo!.idVehiculo,
      'id_empleado': empleado.idEmpleado,
      'FechaAgendamiento': DateFormat('yyyy-MM-dd').format(_fecha!),
      'Hora': _hora,
      'Descripcion': _descCtrl.text,
    };

    final ok = await context.read<AgendaProvider>().crearCita(body);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cita creada exitosamente'),
            backgroundColor: AppColors.primary),
      );
      Navigator.pop(context);
    } else {
      _showError(
          context.read<AgendaProvider>().error ?? 'Error al crear cita');
    }
  }

  /// Empleado preseleccionado en el dropdown: el usuario logueado si aparece
  /// en la lista cargada, si no el primero disponible.
  EmpleadoModel _empleadoPorDefecto(
      BuildContext context, List<EmpleadoModel> empleados) {
    final actual = context.read<AuthProvider>().empleado;
    return empleados.firstWhere(
      (e) => e.idEmpleado == actual?.idEmpleado,
      orElse: () => empleados.first,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agendaProv = context.watch<AgendaProvider>();
    final vehProv = context.watch<VehiculoProvider>();
    final clientes = agendaProv.clientes;
    final vehiculos = _vehiculosCliente(vehProv.all);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva cita')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppColors.paddingStd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<ClienteCatalogo>(
                initialValue: _cliente,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
                items: clientes
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.nombre),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _cliente = v;
                  _vehiculo = null;
                }),
                validator: (v) =>
                    v == null ? 'Selecciona un cliente' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehiculoModel>(
                initialValue: _vehiculo,
                decoration: const InputDecoration(
                  labelText: 'Vehículo',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                items: vehiculos
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                              '${v.placa} — ${v.marca} ${v.modelo}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _vehiculo = v),
                validator: (v) =>
                    v == null ? 'Selecciona un vehículo' : null,
              ),
              if (agendaProv.empleados.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<EmpleadoModel>(
                  initialValue: _empleado ?? _empleadoPorDefecto(context, agendaProv.empleados),
                  decoration: const InputDecoration(
                    labelText: 'Empleado asignado',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: agendaProv.empleados
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.nombre),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _empleado = v),
                ),
              ],
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) {
                    setState(() {
                      _fecha = d;
                      // La hora elegida puede quedar en el pasado al cambiar
                      // de fecha (ej. se pasó a "hoy"): se limpia si ya no
                      // está entre los horarios disponibles.
                      if (_hora != null && !_horarios.contains(_hora)) {
                        _hora = null;
                      }
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _fecha != null
                        ? DateFormat('dd/MM/yyyy').format(_fecha!)
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      color: _fecha != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                // Se reconstruye desde cero cuando cambia la fecha: al ser un
                // FormField, `initialValue` solo aplica en el primer build, y
                // si no se fuerza un nuevo widget con `key` la lista de items
                // (recalculada por `_horarios`) puede quedar desincronizada
                // con la selección previa y bloquear el campo.
                key: ValueKey(_fecha),
                initialValue: _hora,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  prefixIcon: Icon(Icons.access_time),
                ),
                items: _horarios
                    .map((h) => DropdownMenuItem(
                          value: h,
                          child: Text(h),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _hora = v),
                validator: (v) =>
                    v == null ? 'Selecciona una hora' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
