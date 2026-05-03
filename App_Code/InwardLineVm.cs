using System;

[Serializable]
public class InwardLineVm
{
    public string PartId { get; set; }
    public string Qty { get; set; }
    public string Rate { get; set; }

    public InwardLineVm()
    {
        PartId = "0";
        Qty = "";
        Rate = "0";
    }
}
