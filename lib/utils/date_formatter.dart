/// Utilidad centralizada para formateo de fechas.
///
/// Proporciona métodos estáticos para formatear fechas UTC a formatos
/// legibles según el locale del usuario, con conversión automática a hora local.
///
/// **Uso**:
/// - Usar `formatDateTime()` para formato completo con hora (detalles)
/// - Usar `formatDate()` para formato compacto sin hora (listas/tarjetas)
/// - Todas las fechas se convierten automáticamente de UTC a hora local
class DateFormatter {
  /// Formatea una fecha UTC a formato completo legible.
  ///
  /// Convierte la fecha de UTC a hora local y la formatea como:
  /// "dd/MM/yyyy HH:mm" (ej: "12/01/2024 14:30")
  ///
  /// Útil para mostrar fechas en pantallas de detalle donde se necesita
  /// precisión temporal completa.
  ///
  /// [dateTime] - Fecha en UTC (normalmente desde base de datos)
  /// Retorna fecha formateada en hora local del usuario
  static String formatDateTime(DateTime dateTime) {
    // Convertir UTC a hora local
    final localTime = dateTime.toLocal();

    // Formatear manualmente: dd/MM/yyyy HH:mm
    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final year = localTime.year;
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  /// Formatea una fecha UTC a formato compacto legible.
  ///
  /// Convierte la fecha de UTC a hora local y la formatea como:
  /// "dd/MM/yyyy" (ej: "12/01/2024")
  ///
  /// Útil para mostrar fechas en listas o tarjetas donde el espacio es limitado
  /// y no se requiere información de hora.
  ///
  /// [dateTime] - Fecha en UTC (normalmente desde base de datos)
  /// Retorna fecha formateada en hora local del usuario (solo fecha, sin hora)
  static String formatDate(DateTime dateTime) {
    // Convertir UTC a hora local
    final localTime = dateTime.toLocal();

    // Formatear manualmente: dd/MM/yyyy
    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final year = localTime.year;

    return '$day/$month/$year';
  }
}
