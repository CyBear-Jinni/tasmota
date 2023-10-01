import 'dart:convert';

import 'package:http/http.dart';
import 'package:network_tools/network_tools.dart';
import 'package:tasmota/src/tasmota_ip_api/tasmota_ip_api_components.dart';

class HelperFile {
  /// Getting all of the components/gpio configuration of the device.
  /// Doc of all components: https://tasmota.github.io/docs/Components/#tasmota
  Future<List<String>> getAllComponentsOfDevice(
    ActiveHost activeHost,
  ) async {
    final String deviceIp = activeHost.address;
    const String getComponentsCommand = 'cm?cmnd=Gpio';

    Map<String, Map<String, String>>? responseJson;
    final List<String> componentTypeAndName = [];

    try {
      final Response response =
          await get(Uri.parse('http://$deviceIp/$getComponentsCommand'));
      final Map<String, dynamic> temp1ResponseJson =
          json.decode(response.body) as Map<String, dynamic>;

      final Map<String, Map<String, dynamic>> temp2ResponseJson =
          temp1ResponseJson.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      );

      responseJson = temp2ResponseJson.map(
        (key, Map<String, dynamic> value) => MapEntry(
          key,
          value.map(
            (key, value) {
              final MapEntry<String, String> tempEntry =
                  MapEntry(key, value.toString());
              componentTypeAndName.add(key);
              return tempEntry;
            },
          ),
        ),
      );
    } catch (e) {
      logger.e(e);
    }
    if (responseJson == null || responseJson.isEmpty) {
      return [];
    }
    return componentTypeAndName;
  }

  static Future<DeviceEntityAbstract?> addDeviceByTasmotaType({
    required String componentInDeviceNumberLabel,
    required ActiveHost activeHost,
    required CoreUniqueId coreUniqueIdTemp,
  }) async {
    final String? deviceHostName = await activeHost.hostName;
    if (deviceHostName == null) {
      return null;
    }
    final int componentInDeviceNumberLabelAsInt =
        int.parse(componentInDeviceNumberLabel);

    if (!gpioOverviewTasmota.keys.contains(componentInDeviceNumberLabelAsInt) ||
        gpioOverviewTasmota[componentInDeviceNumberLabelAsInt]!.length < 2) {
      logger.w(
        'Tasmota ip does not contain this key, you can add more in [gpioOverviewTasmota]',
      );
      return null;
    }
    final List<String>? componentInDeviceUiLabelAndComment =
        gpioOverviewTasmota[componentInDeviceNumberLabelAsInt];

    if (componentInDeviceNumberLabelAsInt == 0) {
      // UI Label: None
      return null;
    } else if (componentInDeviceNumberLabelAsInt >= 32 &&
        componentInDeviceNumberLabelAsInt <= 39) {
      // UI Label: Button
    } else if (componentInDeviceNumberLabelAsInt >= 64 &&
        componentInDeviceNumberLabelAsInt <= 71) {
      // UI Label: Button_n
    } else if (componentInDeviceNumberLabelAsInt >= 96 &&
        componentInDeviceNumberLabelAsInt <= 103) {
      // UI Label: Button_i
    } else if (componentInDeviceNumberLabelAsInt >= 224 &&
        componentInDeviceNumberLabelAsInt <= 251) {
      // UI Label: Relay
      return TasmotaIpSwitchEntity(
        uniqueId: coreUniqueIdTemp,
        entityUniqueId: EntityUniqueId(
          '$deviceHostName-$componentInDeviceNumberLabel}',
        ),
        cbjEntityName: CbjEntityName(
          '$deviceHostName-${componentInDeviceUiLabelAndComment![0]}',
        ),
        entityOriginalName: EntityOriginalName(
          '$deviceHostName-${componentInDeviceUiLabelAndComment[0]}',
        ),
        deviceOriginalName: DeviceOriginalName(
          '$deviceHostName-${componentInDeviceUiLabelAndComment[0]}',
        ),
        entityStateGRPC: EntityState(EntityStateGRPC.ack.toString()),
        senderDeviceOs: DeviceSenderDeviceOs('Tasmota'),
        senderDeviceModel: DeviceSenderDeviceModel('Tasmota'),
        senderId: DeviceSenderId(),
        compUuid: DeviceCompUuid('34asdfrsd23gggg'),
        stateMassage: DeviceStateMassage('Hello World'),
        powerConsumption: DevicePowerConsumption('0'),
        switchState: GenericSwitchSwitchState(EntityActions.off.toString()),
        deviceHostName: DeviceHostName(deviceHostName),
        deviceLastKnownIp: DeviceLastKnownIp(activeHost.address),
        deviceUniqueId: DeviceUniqueId('0'),
        devicePort: DevicePort('0'),
        deviceMdns: DeviceMdns('0'),
        devicesMacAddress: DevicesMacAddress('0'),
        entityKey: EntityKey('0'),
        requestTimeStamp: RequestTimeStamp('0'),
        lastResponseFromDeviceTimeStamp: LastResponseFromDeviceTimeStamp('0'),
        deviceCbjUniqueId: CoreUniqueId(),
      );
    } else if (componentInDeviceNumberLabelAsInt >= 256 &&
        componentInDeviceNumberLabelAsInt <= 283) {
      // UI Label: Relay_i
    } else if (componentInDeviceNumberLabelAsInt >= 288 &&
        componentInDeviceNumberLabelAsInt <= 291) {
      // UI Label: Led
    } else if (componentInDeviceNumberLabelAsInt >= 320 &&
        componentInDeviceNumberLabelAsInt <= 323) {
      // UI Label: Led_i
    }

    logger.i(
      'Please add new Tasmota device type ${componentInDeviceUiLabelAndComment![0]}',
    );
    return null;
  }
}
