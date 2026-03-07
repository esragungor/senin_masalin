class MockData {
  static final List<String> categories = [
    'E\u011fitici',
    'Hayvanlar Alemi',
    '\u0130yilik ve Empati',
    'Uyku \u00d6ncesi',
    'B\u00fcy\u00fc ve Sihir',
    'Zeka ve Kurnazl\u0131k',
    'Prens ve Prensesler',
    'Komik ve E\u011flenceli',
    'Ke\u015fif ve Macera',
    'Cesaret ve Kahramanl\u0131k'
  ];

  static final List<String> _covers = [
    'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1618331835717-801e976710b2?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&h=400&fit=crop',
    'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400&h=400&fit=crop',
  ];

  static List<Map<String, dynamic>> _generateReadyTales() {
    List<Map<String, dynamic>> tales = [];
    int idCounter = 1;
    for (String category in categories) {
      for (int i = 1; i <= 6; i++) {
        tales.add({
          'id': 'ready_\$idCounter',
          'category': category,
          'title': '\$category Masal\u0131 \$i',
          'timeAgo': 'Haz\u0131r Masal',
          'coverUrl': _covers[i % _covers.length],
        });
        idCounter++;
      }
    }
    return tales;
  }

  static final List<Map<String, dynamic>> readyTales = _generateReadyTales();

  static List<Map<String, dynamic>> myTales = [];
}
