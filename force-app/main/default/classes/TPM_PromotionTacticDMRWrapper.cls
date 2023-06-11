/*******************************************************************************************************
* @Name         : TPM_PromotionTacticDMRWrapper
* @unit Test    : TPM_PromotionTacticDMRWrapperTest
* @author       : PwC Team
* @date         : 03/24/2023
* @description  : Wrapper Class to for Preparing Response JSON 
				  for Promotion Tactic Dailly Measure Table.
*******************************************************************************************************/
public class TPM_PromotionTacticDMRWrapper {
    
    public String type;
    public String salesorg;
    public List<Volumes> volumes;

    /*******************************************************************************************************
    * @Name         : Volumes
    * @unit Test    : VolumesTest
    * @author       : PwC Team
    * @date         : 03/24/2023
    * @description  : Wrapper Class to for Preparing Response JSON 
                      for Promotion Tactic Dailly Measure Table.
    *******************************************************************************************************/
    public class Volumes {
        public String startdate;
        public List<Rows> rows;
    }
    
    /*******************************************************************************************************
    * @Name         : Rows
    * @unit Test    : RowsTest
    * @author       : PwC Team
    * @date         : 03/24/2023
    * @description  : Wrapper Class to for Preparing Response JSON 
                      for Promotion Tactic Dailly Measure Table.
    *******************************************************************************************************/
    public class Rows {
        public String prd;
        public String acc;
        public String prm;
        public Double value;
    }
    
    /******************************************************************************************************** 
    @methodname 	parse
    @createdDate 	03/24/2023
    @return         TPM_PromotionTacticDMRWrapper
    @param          json
    @description	returns the deserialized JSON
    *********************************************************************************************************/ 
    public static TPM_PromotionTacticDMRWrapper parse(String json) {
        return (TPM_PromotionTacticDMRWrapper) System.JSON.deserialize(json, TPM_PromotionTacticDMRWrapper.class);
    }
}