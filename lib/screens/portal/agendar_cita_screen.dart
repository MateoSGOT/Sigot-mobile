import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/portal_provider.dart';

class AgendarCitaScreen extends StatefulWidget {
  const AgendarCitaScreen({super.key});

  @override
  State<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends State<AgendarCitaScreen> {
  int? _idVehiculo;
  DateTime? _fecha;
  String? _hora;
  int? _idEmpleado;
  final _descCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  List<String> _buildSlots() {
    final s = <String>[];
    for (var m = 8 * 60; m <= 18 * 60; m += 30) {
      final h = m ~/ 60, mm = m % 60;
      s.add('${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}');
    }
    return s;
  }

  /// Horas disponibles para la fecha elegida: si es hoy, oculta las que ya
  /// pasaron (antes se mostraban todas y solo se validaba al enviar).
  List<String> get _slots {
    final base = _buildSlots();
    if (_fecha == null) return base;
    final ahora = DateTime.now();
    final esHoy = _fecha!.year == ahora.year &&
        _fecha!.month == ahora.month &&
        _fecha!.day == ahora.day;
    if (!esHoy) return base;
    return base.where((h) {
      final p = h.split(':');
      final slot = DateTime(
          ahora.year, ahora.month, ahora.day, int.parse(p[0]), int.parse(p[1]));
      return slot.isAfter(ahora);
    }).toList();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  String _fmtFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        _fecha = d;
        if (_hora != null && !_slots.contains(_hora)) _hora = null;
        _idEmpleado = null;
      });
      context.read<PortalProvider>().loadEmpleadosDisponibles(_fmtFecha(d));
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_idVehiculo == null || _fecha == null || _hora == null) {
      setState(() => _error = 'Vehículo, fecha y hora son obligatorios.');
      return;
    }
    // La fecha y hora deben ser futuras.
    final parts = _hora!.split(':');
    final dt = DateTime(_fecha!.year, _fecha!.month, _fecha!.day,
        int.parse(parts[0]), int.parse(parts[1]));
    if (!dt.isAfter(DateTime.now())) {
      setState(() => _error = 'La fecha y hora deben ser futuras.');
      return;
    }

    setState(() => _saving = true);
    final err = await context.read<PortalProvider>().crearCita({
      'Id_Vehiculo': _idVehiculo,
      'Fecha': _fmtFecha(_fecha!),
      'Hora': _hora,
      'Descripcion': _descCtrl.text.trim(),
      'Id_Empleado': _idEmpleado ?? '',
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cita agendada exitosamente'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiculos = context.read<PortalProvider>().vehiculos;
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar cita')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                ],
              ),
            ),
          _label('Vehículo'),
          DropdownButtonFormField<int>(
            value: _idVehiculo,
            decoration: _dec('Selecciona tu vehículo', Icons.directions_car),
            items: vehiculos
                .map((v) => DropdownMenuItem(
                      value: v.idVehiculo,
                      child: Text('${v.placa} — ${v.marca}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _idVehiculo = v),
          ),
          const SizedBox(height: 16),
          _label('Fecha'),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _pickFecha,
            child: InputDecorator(
              decoration: _dec('Selecciona la fecha', Icons.calendar_today),
              child: Text(
                _fecha == null ? 'dd/mm/aaaa' : _fmtFecha(_fecha!),
                style: TextStyle(
                    color: _fecha == null
                        ? AppColors.textMuted
                        : AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Hora'),
          DropdownButtonFormField<String>(
            key: ValueKey(_fecha),
            value: _hora,
            decoration: _dec('Selecciona la hora', Icons.schedule),
            items: _slots
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: (v) => setState(() => _hora = v),
          ),
          const SizedBox(height: 16),
          _label('Mecánico / técnico (opcional)'),
          Consumer<PortalProvider>(
            builder: (ctx, prov, _) {
              final disponibles = prov.empleadosDisponibles;
              return DropdownButtonFormField<int>(
                key: ValueKey('emp-${_fecha ?? ''}'),
                value: _idEmpleado,
                decoration: _dec(
                    _fecha == null
                        ? 'Elige primero una fecha'
                        : 'Cualquiera disponible',
                    Icons.engineering),
                items: disponibles
                    .map((e) => DropdownMenuItem(
                          value: e.idEmpleado,
                          enabled: e.disponible,
                          child: Text(e.disponible
                              ? e.nombre
                              : '${e.nombre} (no disponible)'),
                        ))
                    .toList(),
                onChanged: _fecha == null
                    ? null
                    : (v) => setState(() => _idEmpleado = v),
              );
            },
          ),
          const SizedBox(height: 16),
          _label('Descripción (opcional)'),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            maxLength: 300,
            decoration: _dec('Motivo de la cita...', Icons.description),
          ),
          const SizedBox(height: 8),
          _saving
              ? Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppBrand.buttonEmerald,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                )
              : _submitButton(),
        ],
      ),
    );
  }

  Widget _submitButton() => Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppBrand.buttonEmerald,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _submit,
            child: const SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Agendar cita',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7, left: 2),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      );

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x1A000000)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x1A000000)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      );
}
