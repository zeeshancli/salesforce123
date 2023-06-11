/*******************************************************************************************************
* @Name         : TPM_AccountProductMeasureWrapper
* @unit Test    : TPM_AccountProductMeasureWrapperTest
* @author       : PwC Team
* @date         : 03/24/2023
* @description  : Wrapper Class to for Preparing Response JSON 
				  for Account Product Measure Table
*******************************************************************************************************/
public class TPM_AccountProductMeasureWrapper {

    // Attributes to store Measure Code and 
    // Price List
	public String type;
	public List<Prices> prices;

    /*******************************************************************************************************
    * @Name         : Prices
    * @unit Test    : PricesTest
    * @author       : PwC Team
    * @date         : 03/24/2023
    * @description  : Wrapper Class to for Preparing Response JSON 
				  	  for Account Product Measure Table
    *******************************************************************************************************/
	public class Prices {
		public String acc;
		public String prd;
		public Double value;
		public String datefrom;
		public String datethru;
	}
    
    /******************************************************************************************************** 
    @methodname 	parse
    @createdDate 	03/24/2023
    @return         TPM_AccountProductMeasureWrapper
    @param          json
    @description	returns the deserialized JSON
    *********************************************************************************************************/ 
    public static TPM_AccountProductMeasureWrapper parse(String json) {
		return (TPM_AccountProductMeasureWrapper) System.JSON.deserialize(json, TPM_AccountProductMeasureWrapper.class);
	}

}