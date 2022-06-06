import 'package:data_table_2/data_table_2.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:provider/provider.dart';

class LoadSequencesKeepAlive extends StatefulWidget {
  const LoadSequencesKeepAlive({Key? key}) : super(key: key);

  @override
  State<LoadSequencesKeepAlive> createState() => _LoadSequencesKeepAliveState();
}

class _LoadSequencesKeepAliveState extends State<LoadSequencesKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadSequences();
  }

  @override
  bool get wantKeepAlive => true;
}

class LoadSequences extends HookWidget {
  String getProfileStatusText(int value) {
    switch (value) {
      case 1:
        return "INVALID";
      case 2:
        return "VALID";
      default:
        return "N/A";
    }
  }

  Color getProfileStatusColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedSequences = context.select((KeysightCAPI k) => k.savedSequences);
    final loadedProfiles = context.select((KeysightCAPI k) => k.loadedProfiles);
    final profileStatuses =
        context.select((KeysightCAPI k) => k.profilesStatuses);
    final backend = Provider.of<KeysightCAPI>(context, listen: false);

    final profileValue = useState(List<int>.filled(8, 0));

    return Padding(
      padding: const EdgeInsets.all(8),
      child: DataTable(
        headingRowColor:
            MaterialStateColor.resolveWith((states) => Colors.blue.shade900),
        columns: [
          DataColumn(
            label: Text(
              'Sequence #',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Currently Loaded Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Select Profile to Load',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Load',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        rows: List<DataRow>.generate(
          8,
          (index) => DataRow(
            color: MaterialStateProperty.resolveWith<Color>((states) {
              if (index % 2 == 0) return Colors.grey.shade700;
              return Colors.grey.shade800;
            }),
            cells: <DataCell>[
              DataCell(
                Text(
                  (index + 1).toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  loadedProfiles.elementAt(index),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              DataCell(
                Text(
                  getProfileStatusText(profileStatuses.elementAt(index)),
                  style: TextStyle(
                      color: getProfileStatusColor(
                          profileStatuses.elementAt(index))),
                ),
              ),
              DataCell(IntrinsicWidth(
                child: DropdownButtonFormField(
                  value: profileValue.value.elementAt(index),
                  items: List.generate(
                    savedSequences.length,
                    (idx) => DropdownMenuItem(
                      child: Text(savedSequences.elementAt(idx)),
                      value: idx,
                    ),
                  ),
                  onChanged: (int? value) {
                    profileValue.value = List.from(profileValue.value)
                      ..[index] = value ?? 0;
                    print(profileValue.value);
                  },
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.blueAccent,
                  iconEnabledColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.4),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.blueAccent,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(8.0),
                  ),
                ),
              )),
              DataCell(
                ElevatedButton(
                  child: Text("Load Profile"),
                  onPressed: () {
                    //backend.loadProfile()
                    print(
                        "load profile called on $index ${profileValue.value.elementAt(index)}");
                    final idxToSend = profileValue.value.elementAt(index);
                    if (idxToSend < savedSequences.length) {
                      final name =
                          savedSequences.elementAt(idxToSend).toNativeUtf8();
                      backend.loadProfile(name, index);
                      malloc.free(name);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
