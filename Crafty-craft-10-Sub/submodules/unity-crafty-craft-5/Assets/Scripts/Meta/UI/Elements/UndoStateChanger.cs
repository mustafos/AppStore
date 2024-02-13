using System.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UndoStateChanger : MonoBehaviour
{
    [SerializeField] private Button button;
    [SerializeField] private Image iconImage;
    [SerializeField] private TextMeshProUGUI text;
    [SerializeField] private Sprite selectedSprite;
    [SerializeField] private Sprite unselectedSprite;
    [SerializeField] private Color textSelectedColor;
    [SerializeField] private Color textUnselectedColor;

    private void Start()
    {
        button.onClick.AddListener(ButtonClicked);
    }

    private async void ButtonClicked()
    {
        iconImage.sprite = selectedSprite;
        text.color = textSelectedColor;
        await Task.Delay(100);
        iconImage.sprite = unselectedSprite;
        text.color = textUnselectedColor;
    }
}
