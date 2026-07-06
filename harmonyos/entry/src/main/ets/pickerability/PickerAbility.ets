import { UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class PickerAbility extends UIAbility {
  onCreate(want: Want): void {
    // want may contain tempDir
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/PickerPage', (err) => {
      if (err) {
        console.error('PickerAbility', 'loadContent failed: ' + JSON.stringify(err));
        this.context.terminateSelf();
      }
    });
  }
}
