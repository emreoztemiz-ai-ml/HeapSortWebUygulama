import 'package:flutter/material.dart';

void main() {
  runApp(const HeapSortApp());
}

class HeapSortApp extends StatelessWidget {
  const HeapSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heap Sort Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HeapSortPage(),
    );
  }
}

class HeapSortPage extends StatefulWidget {
  const HeapSortPage({super.key});

  @override
  State<HeapSortPage> createState() => _HeapSortPageState();
}

class _HeapSortPageState extends State<HeapSortPage> {
  final TextEditingController _controller = TextEditingController();
  List<int> _numbers = [];
  List<int> _originalNumbers = [];
  List<String> _steps = [];
  bool _isSorting = false;
  int _currentStepIndex = -1;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parseInput() {
    setState(() {
      _numbers = [];
      _originalNumbers = [];
      _steps = [];
      _currentStepIndex = -1;
      
      final input = _controller.text.trim();
      if (input.isEmpty) return;

      final parts = input.split(RegExp(r'[,\s]+'));
      for (final part in parts) {
        try {
          final number = int.parse(part);
          _numbers.add(number);
          _originalNumbers.add(number);
        } catch (e) {
          // Eğer sayı değilse, yoksay
        }
      }
    });
  }

  Future<void> _startHeapSort() async {
    if (_numbers.isEmpty) return;
    
    setState(() {
      _isSorting = true;
      _steps = [];
      _currentStepIndex = -1;
    });
    
    await _heapSort(_numbers);
    
    setState(() {
      _isSorting = false;
    });
  }

  Future<void> _nextStep() async {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    }
  }

  Future<void> _previousStep() async {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  Future<void> _heapSort(List<int> arr) async {
    List<int> tempArr = List.from(arr);
    _steps.add("Başlangıç Dizisi: ${tempArr.toString()}");
    
    // Heap oluşturma (Heapify)
    _steps.add("Heap oluşturma (Heapify) işlemi başlıyor");
    int n = tempArr.length;
    
    // Max heap oluşturma
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      await _heapify(tempArr, n, i);
    }
    
    _steps.add("Max heap oluşturuldu: ${tempArr.toString()}");
    
    // Sırayla heapten eleman çıkarma ve sıralama
    for (int i = n - 1; i > 0; i--) {
      // Kök elemanı (en büyük) sona taşı
      int temp = tempArr[0];
      tempArr[0] = tempArr[i];
      tempArr[i] = temp;
      
      _steps.add("En büyük eleman ${temp} sona taşındı: ${tempArr.toString()}");
      
      // Kalan alt ağacı tekrar heapify yap
      await _heapify(tempArr, i, 0);
    }
    
    _steps.add("Sıralama tamamlandı: ${tempArr.toString()}");
    
    setState(() {
      _numbers = tempArr;
    });
  }

  Future<void> _heapify(List<int> arr, int n, int i) async {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;
    
    String step = "Heapify i=$i için: ";
    List<int> before = List.from(arr);
    
    // Sol çocuk kökten büyükse
    if (left < n && arr[left] > arr[largest]) {
      largest = left;
    }
    
    // Sağ çocuk en büyükten büyükse
    if (right < n && arr[right] > arr[largest]) {
      largest = right;
    }
    
    // En büyük kök değilse
    if (largest != i) {
      int swap = arr[i];
      arr[i] = arr[largest];
      arr[largest] = swap;
      
      step += "Yer değiştirme: $swap <-> ${arr[i]}, ";
      
      // Alt ağacı tekrar heapify yap
      await _heapify(arr, n, largest);
    }
    
    if (before.toString() != arr.toString()) {
      step += "Dizi: ${arr.toString()}";
      _steps.add(step);
    }
  }

  void _resetAll() {
    setState(() {
      _numbers = List.from(_originalNumbers);
      _steps = [];
      _currentStepIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heap Sort Algoritması'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sıralanacak sayıları girin (virgül veya boşlukla ayırın):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Örn: 12, 3, 5, 7, 19, 2',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _parseInput,
                  child: const Text('Sayıları Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_numbers.isNotEmpty) ...[
              Text(
                'Sayı Dizisi: ${_numbers.toString()}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isSorting ? null : _startHeapSort,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Heap Sort Başlat'),
                  ),
                  ElevatedButton(
                    onPressed: _isSorting ? null : _resetAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sıfırla'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (_steps.isNotEmpty) ...[
              const Text(
                'Adımlar:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _currentStepIndex + 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '${index + 1}. ${_steps[index]}',
                                style: TextStyle(
                                  color: index == _currentStepIndex ? Colors.blue : Colors.black,
                                  fontWeight: index == _currentStepIndex ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _currentStepIndex > 0 ? _previousStep : null,
                            child: const Text('Önceki Adım'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _currentStepIndex < _steps.length - 1 ? _nextStep : null,
                            child: const Text('Sonraki Adım'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}