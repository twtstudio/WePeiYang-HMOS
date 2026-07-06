import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { AbilityAware, AbilityPluginBinding } from '@ohos/flutter_ohos';
import { picker } from '@kit.CoreFileKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

const TAG = 'ImagePickerPlugin';

export default class ImagePickerPlugin implements FlutterPlugin, AbilityAware {
  private channel: MethodChannel | null = null;
  private uiContext: common.UIAbilityContext | null = null;

  getUniqueClassName(): string {
    return 'ImagePickerPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(
      binding.getBinaryMessenger(),
      'com.twt.service/picker'
    );
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiContext = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.uiContext = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    switch (call.method) {
      case 'pickImages':
        await this.pickImages(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private async pickImages(result: MethodResult): Promise<void> {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const options = new picker.PhotoSelectOptions();
      options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 3;
      const res = await photoPicker.select(options);
      const uris: string[] = res.photoUris as string[];

      // Copy to temp dir for Flutter access
      const cacheDir = this.uiContext?.cacheDir || '';
      const tempDir = cacheDir + '/picker_temp';
      await fileIo.mkdir(tempDir, true);
      const finalPaths: string[] = [];
      for (let i = 0; i < uris.length; i++) {
        try {
          const srcFile = await fileIo.open(uris[i], fileIo.OpenMode.READ_ONLY);
          const ext = uris[i].split('.').pop() || 'jpg';
          const dstPath = tempDir + '/img_' + i + '.' + ext;
          const dstFile = await fileIo.open(dstPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
          await fileIo.copyFile(srcFile.fd, dstFile.fd);
          await fileIo.close(srcFile);
          await fileIo.close(dstFile);
          finalPaths.push(dstPath);
        } catch (copyErr) {
          console.error(TAG, 'copy ' + i + ' failed: ' + JSON.stringify(copyErr));
        }
      }
      console.info(TAG, 'pickImages success: ' + finalPaths.length + ' files');
      result.success(finalPaths);
    } catch (e) {
      console.error(TAG, 'pickImages failed: ' + JSON.stringify(e));
      result.success([]);
    }
  }
}
