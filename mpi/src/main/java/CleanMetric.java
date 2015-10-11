/**
 * Keep track of bad data points
 */
public class CleanMetric {
    public int negativeCount;
    public int missingValues;
    public int properSplitData;
    public int nonProperSplitData;
    public int constantStock;

    public String serialize() {
        StringBuilder sb = new StringBuilder();
        sb.append("Negative: ").append(negativeCount);
        sb.append("MissingValues: ").append(missingValues);
        sb.append("ProperSplitData: ").append(properSplitData);
        sb.append("NonProperSplitData: ").append(nonProperSplitData);
        sb.append("ConstantStock: ").append(constantStock);

        return sb.toString();
    }
}
