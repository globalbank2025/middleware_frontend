
//using Oracle.DataAccess.Client;
 
namespace WebServices
{
    public class Bill_Data
    {
        public string manifest_id { get; set; }
        public string customer_id { get; set; }
        public string name { get; set; }
        public string bill_id { get; set; }
        public string bill_desc { get; set; }
        public string reason { get; set; }
        public bool partial_pay_allowed { get; set; }
        public decimal amount_due { get; set; }
        public string due_dt { get; set; }

    }

    public class SafariMsg
    {
        public string code;
        public string message;
    }
    //[XmlRoot("Customer")]
    public class MiniStatement
    {
        public string Acc;
        public string TRNREF;
        public string TXNDT;
        //public string TXNDT;
        public string VALDT;
        public string DRCR;
        public decimal LCYAMT;
        public string EXT_TRN_CODE_DESC;
        public string AUTHSTAT;
    }
    public class BillPayData
    {
        public string manifest_id { get; set; }
        public string bill_id { get; set; }
        public string amount { get; set; }
        public string paid_dt { get; set; }
        public string payee_mobile { get; set; }
        public string paid_at { get; set; }
        public string txn_code { get; set; }

    }

    public class CustInfo
    {
        public int statusCode { get; set; }
        public string message { get; set; }
        public string AccountNo { get; set; }
        public string CustomerData { get; set; } 
    }

    public class CurrencyInfo
    {
        public string message { get; set; }
        public string Currency { get; set; }
        public string Rate { get; set; }
        public string Date { get; set; }
    }

    public class TransactionInfo
    {
        public int statusCode { get; set; }
        public string message { get; set; }
        public string BankRefNo { get; set; }
    }

    public class ResponseMsg
    {
        public int StatusCode { get; set; }
        public string Status { get; set; }
        public string message { get; set; }
        public string ErrorMsg { get; set; }
    }

    public class ReturnMsg
    {
        public string message { get; set; }
    }

    public class FixedValue
    {
        public string Name { get; set; }
        public string Parameter { get; set; }
        public string Value { get; set; }
    }

    public class SuccessMsg
    {
        public int ResponseCode { get; set; }
        public string confirmation_code { get; set; }

    }

    public class BillerList
    {
        public string ServiceCode;
        public string ServiceName;
        public string BillType;
        public string ReferenceId;
        public string BillerName; 
    }
    /// <summary>
    /// Summary description for DemoWebService
    /// </summary>
    /// 

    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [ScriptService]
    public class DemoWebService : System.Web.Services.WebService
    {
        public static string GlobalVariable;
        private TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
        SqlCommand com = null;
        SqlDataReader SQLreader = null;
        SqlConnection con = null;
        SqlCommand com1 = null;
        SqlDataReader SQLreader1 = null;
        SqlConnection con1 = null;
        public XmlDocument ToXmlDocument(XElement xelement)
        {
            var xmldoc = new XmlDocument();
            xmldoc.Load(xelement.CreateReader());
            return xmldoc;
        }

        public static string FormBufferToString()
        {
            HttpRequest Request = HttpContext.Current.Request;

            if (Request.TotalBytes > 0)
                return Encoding.Default.GetString(Request.BinaryRead(Request.TotalBytes));

            return string.Empty;
        }


        [SoapDocumentMethod(ParameterStyle = SoapParameterStyle.Bare)]
        [WebMethod]
        public void ApplyTransactionRequest()
        {
            HttpRequest Request = HttpContext.Current.Request;
            var formBuffer = string.Empty;

            if (Request.ContentType.StartsWith("application/") || Request.ContentType == "application/x-www-form-urlencoded")
            {
                formBuffer = FormBufferToString();
            }

            XmlDocument[] xmlparams = new XmlDocument[3];
            int LogId = 0;
            string ServiceCode = "TLBR";
            string[] PostStatus = new string[10];
            string BankAccountNo = null;
            string SendingIdentityID = null;
            string OrderId = null;
            string Amount = null;
            string SendingTime = null;
            string BranchCode = null;
            string DescriptionValue = "ErrorDescription";
            string CommandID = ExtractData(GetIndex("Header", formBuffer), "<goa:CommandID", ">", "</goa:CommandID>", formBuffer);
            //string OwnLoginID = "ethiomm";
            //string OwnPassword = "7wfoK9zz3Alst3xt0V336ATOtczGG2e/xUQ9JBDRhuQ=";
            string LoginID = ExtractData(GetIndex("Header", formBuffer), "<goa:LoginID", ">", "</goa:LoginID>", formBuffer);
            string Password = ExtractData(GetIndex("Header", formBuffer), "<goa:Password", ">", "</goa:Password>", formBuffer);
            XElement root = null;
            //get username and password from record
            string TxnType = null;
            if (CommandID == "GOAQueryBankAccountDetail")
                TxnType = "Fetch";
            if(CommandID == "GOACPStoBankAccount")
                TxnType = "Post";
            int MethodId = Int32.Parse(GetAPIParameters(ServiceCode,TxnType,"MethodId"));
            string SavedUserID = GetAPIParameters(ServiceCode,TxnType,"UserName");
            string SavedPassword = GetAPIParameters(ServiceCode, TxnType, "Password");
            LogId = RecordLog(MethodId, "RequestDateTime", "");

            if (formBuffer == string.Empty)
            {
                XNamespace ns2 = "http://cps.huawei.com/cpsinterface/goa/at";
                XNamespace ns1 = "http://cps.huawei.com/cpsinterface/goa";
                XNamespace ns3 = "http://tempuri.org/";
                XNamespace SoapNs = "http://www.w3.org/2003/05/soap-envelope";
                XNamespace TempNs = "http://tempuri.org/";
                PostStatus[0] = "-1";
                PostStatus[1] = "Fail";
                PostStatus[2] = "Invalid Request";
                LogId = RecordLog(LogId, "RequestStatus", PostStatus[1]);
                root = new XElement(SoapNs + "Envelope",
                        new XAttribute(XNamespace.Xmlns + "soap", SoapNs),
                        new XElement(SoapNs + "Body", new XElement(ns3 + "ApplyTransactionResponse",
                        new XAttribute("xmlns", ns1.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns2", ns2.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns3", ns3.NamespaceName),
                        new XElement(ns2 + "ResponseCode", PostStatus[0]),
                        new XElement(ns2 + "ResponseDesc", PostStatus[1]),
                        new XElement(ns2 + "Parameters",
                        new XElement(ns1 + "Parameter",
                            new XElement(ns1 + "Key", DescriptionValue),
                            new XElement(ns1 + "Value", PostStatus[2])
                            )
                        )))
                    );
            }

            else if (CommandID != "GOAQueryBankAccountDetail" && CommandID != "GOACPStoBankAccount")
            {
                XNamespace ns2 = "http://cps.huawei.com/cpsinterface/goa/at";
                XNamespace ns1 = "http://cps.huawei.com/cpsinterface/goa";
                XNamespace ns3 = "http://tempuri.org/";
                XNamespace SoapNs = "http://www.w3.org/2003/05/soap-envelope";
                XNamespace TempNs = "http://tempuri.org/";
                PostStatus[0] = "-1";
                PostStatus[1] = "Fail";
                PostStatus[2] = "Invalid Transaction Request";
                LogId = RecordLog(LogId, "RequestStatus", PostStatus[1]);
                root = new XElement(SoapNs + "Envelope",
                        new XAttribute(XNamespace.Xmlns + "soap", SoapNs),
                        new XElement(SoapNs + "Body", new XElement(ns3 + "ApplyTransactionResponse",
                        new XAttribute("xmlns", ns1.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns2", ns2.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns3", ns3.NamespaceName),
                        new XElement(ns2 + "ResponseCode", PostStatus[0]),
                        new XElement(ns2 + "ResponseDesc", PostStatus[1]),
                        new XElement(ns2 + "Parameters",
                        new XElement(ns1 + "Parameter",
                            new XElement(ns1 + "Key", DescriptionValue),
                            new XElement(ns1 + "Value", PostStatus[2])
                            )
                        )))
                    );
            }
            //else if (LoginID != SavedUserID || Password != SavedPassword)
            else if (LoginID != SavedUserID)
            {
                XNamespace ns2 = "http://cps.huawei.com/cpsinterface/goa/at";
                XNamespace ns1 = "http://cps.huawei.com/cpsinterface/goa";
                XNamespace ns3 = "http://tempuri.org/";
                XNamespace SoapNs = "http://www.w3.org/2003/05/soap-envelope";
                XNamespace TempNs = "http://tempuri.org/";
                PostStatus[0] = "-1";
                PostStatus[1] = "Fail";
                PostStatus[2] = "Invalid Credentials";
                LogId = RecordLog(LogId, "RequestStatus", PostStatus[1]);
                root = new XElement(SoapNs + "Envelope",
                        new XAttribute(XNamespace.Xmlns + "soap", SoapNs),
                        new XElement(SoapNs + "Body", new XElement(ns3 + "ApplyTransactionResponse",
                        new XAttribute("xmlns", ns1.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns2", ns2.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns3", ns3.NamespaceName),
                        new XElement(ns2 + "ResponseCode", PostStatus[0]),
                        new XElement(ns2 + "ResponseDesc", PostStatus[1]),
                        new XElement(ns2 + "Parameters",
                        new XElement(ns1 + "Parameter",
                            new XElement(ns1 + "Key", DescriptionValue),
                            new XElement(ns1 + "Value", PostStatus[2])
                            )
                        )))
                    );
            }
            //Send the transaction to CBS
            else if (CommandID == "GOAQueryBankAccountDetail")
            { 
                XNamespace ns2 = "http://cps.huawei.com/cpsinterface/goa/at";
                XNamespace ns1 = "http://cps.huawei.com/cpsinterface/goa";
                XNamespace ns3 = "http://tempuri.org/";
                XNamespace SoapNs = "http://www.w3.org/2003/05/soap-envelope";
                XNamespace TempNs = "http://tempuri.org/";
                SendingTime = ExtractData(GetIndex("Header", formBuffer), "<goa:Timestamp", ">", "</goa:Timestamp>", formBuffer);
                BankAccountNo = ExtractData(GetIndex("BankCardNumber", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                SendingIdentityID = ExtractData(GetIndex("IntiatorMSISDN", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                OrderId = ExtractData(GetIndex("Header", formBuffer), "<goa:Timestamp", ">", "</goa:Timestamp>", formBuffer);
                LogId = RecordLog(LogId, "IncomingRequestEntity", SendingIdentityID);
                LogId = RecordLog(LogId, "IncomingRequestValue", BankAccountNo);
                LogId = RecordLog(LogId, "IncomingRequestRefNo", OrderId); 
                LogId = RecordLog(LogId, "RequestStatus", "Ok");
                PostStatus = FetchNameBalFromCBS(SendingIdentityID, BankAccountNo, "TLB", "NAME");
                //Record KYC status in ESB database
                //if (PostStatus[0] == "0")
                    //LogId = RecordLog(LogId, "ReplyStatus", "KYC Pass");
                DescriptionValue = "HolderName";
                LogId = RecordLog(LogId, "ResponseStatus", PostStatus[1]);
                LogId = RecordLog(LogId, "ResponseEntity", SendingIdentityID);
                LogId = RecordLog(LogId, "Responsevalue", PostStatus[2]);

                root = new XElement(SoapNs + "Envelope",
                        new XAttribute(XNamespace.Xmlns + "soap", SoapNs),
                        new XElement(SoapNs + "Body", new XElement(ns3 + "ApplyTransactionResponse",
                        new XAttribute("xmlns", ns1.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns2", ns2.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "ns3", ns3.NamespaceName),
                        new XElement(ns2 + "ResponseCode", PostStatus[0]),
                        new XElement(ns2 + "ResponseDesc", PostStatus[1]),
                        new XElement(ns2 + "Parameters",
                        new XElement(ns1 + "Parameter",
                            new XElement(ns1 + "Key", DescriptionValue),
                            new XElement(ns1 + "Value", PostStatus[2])
                            )
                        )))
                    );
            }
            else if (CommandID == "GOACPStoBankAccount")
            {
                XNamespace at = "http://cps.huawei.com/cpsinterface/goa/at";
                XNamespace goa = "http://cps.huawei.com/cpsinterface/goa";
                XNamespace tem = "http://tempuri.org/";
                XNamespace SoapNs = "http://www.w3.org/2003/05/soap-envelope";
                //XNamespace TempNs = "http://tempuri.org/";
                BankAccountNo = ExtractData(GetIndex("BankAccountNo", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                SendingIdentityID = ExtractData(GetIndex("SendingIdentityID", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                OrderId = ExtractData(GetIndex("OrderId", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                Amount = ExtractData(GetIndex("Amount", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                SendingTime = ExtractData(GetIndex("SendingTime", formBuffer), "<goa:Value", ">", "</goa:Value>", formBuffer);
                //chcek for duplicated reference numebr
                //if (Check_Duplicate_RefNo(ServiceCode, OrderId) == true)
                //{
                //    HttpContext.Current.Response.Clear();
                //    HttpContext.Current.Response.End();
                //}
                LogId = RecordLog(LogId, "IncomingRequestEntity", SendingIdentityID);
                LogId = RecordLog(LogId, "IncomingRequestValue", BankAccountNo);
                LogId = RecordLog(LogId, "IncomingRequestRefNo", OrderId);
                LogId = RecordLog(LogId, "RequestStatus", "Ok");
                string SourceName = GetAPIParameters(ServiceCode, "Post", "SourceName"); //ECX
                string ProductName = GetAPIParameters(ServiceCode, "Post", "ProductName"); //TLBI
                string OffSetAccNo = GetOffSetAccountNo("TLBR");//"1045440"
                //check the account is valid for transaction
                //PostStatus = FetchNameBalFromCBS(ServiceCode, BankAccountNo, SourceName, "Name");
                //if (PostStatus[0] == "0")
                //{
                if (BankAccountNo.Length < 13)
                    BranchCode = "000";
                else
                    BranchCode = BankAccountNo.Substring(0, 3);
                PostStatus = PostRequestToCBS(OffSetAccNo, SendingIdentityID, BankAccountNo, BranchCode, OrderId, SendingTime, Amount, SourceName, ProductName, "Fund Transfer");
                DescriptionValue = "Bank_Transaction_ID";
                //}
                LogId = RecordLog(LogId, "ResponseStatus", PostStatus[1]);
                LogId = RecordLog(LogId, "ResponseEntity", SendingIdentityID);
                LogId = RecordLog(LogId, "Responsevalue", Amount);
                LogId = RecordLog(LogId, "ResponseRefNo", PostStatus[2]);

                root = new XElement(SoapNs + "Envelope",
                        new XAttribute(XNamespace.Xmlns + "soap", SoapNs),
                        new XElement(SoapNs + "Body", new XElement(tem + "ApplyTransactionResponse",
                        new XAttribute(XNamespace.Xmlns + "at", at.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "goa", goa.NamespaceName),
                        new XAttribute(XNamespace.Xmlns + "tem", tem.NamespaceName),
                        new XElement(at + "ResponseCode", PostStatus[0]),
                        new XElement(at + "ResponseDesc", PostStatus[1]),
                        new XElement(at + "Parameters",
                        new XElement(goa + "Parameter",
                            new XElement(goa + "Key", DescriptionValue),
                            new XElement(goa + "Value", PostStatus[2])
                            )
                        )))
                    );
            }
        
            var xmldoc = new XmlDocument();
            xmldoc = ToXmlDocument(root);
            root.RemoveAttributes();
            //return xmldoc; //this also works when the return type chnaged from void to XmlDocument
            HttpContext.Current.Response.ContentType = "application/soap+xml ";
            HttpContext.Current.Response.Write(root);
            HttpContext.Current.Response.End();
            //return root;
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        //public List<BillerList> AllBillerlist()
        public void GetFixedValue(string Name, string Parameter)
        {
            FixedValue fixedValue = new FixedValue();
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            fixedValue.Name = Name;
            fixedValue.Parameter = Parameter;
            if(String.IsNullOrEmpty(Name) || String.IsNullOrEmpty(Parameter))
                goto XXX;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            com = new SqlCommand("SELECT * FROM Setting WHERE Name = '" + Name + "' AND Parameter = '" + Parameter + "' AND Status = 'Active'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                {
                    fixedValue.Value = reader["Value"].ToString();
                }
            }
            reader.Close();
            XXX:
            //return BillerList;
            string jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(fixedValue);
            var json = JToken.Parse(jsonString.ToString());
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(JsonConvert.SerializeObject(json));
            HttpContext.Current.Response.End();
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        //public List<BillerList> AllBillerlist()
        public void AllBillerlist()
        {
            List<BillerList> BillerList = new List<BillerList>();
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            com = new SqlCommand("SELECT S.ServiceCode, B.BillerName, S.ServiceName, S.[Description] AS ReferenceId, S.[Status] AS BillType  FROM Billers B, [Services] S WHERE B.BId = S.Biller AND S.[Status] IN ('Load','Pay')", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                while(reader.Read())
                {
                    BillerList bill = new BillerList();
                    bill.BillerName = reader["BillerName"].ToString();
                    bill.ServiceCode = reader["ServiceCode"].ToString();
                    bill.ServiceName = reader["ServiceName"].ToString();
                    bill.BillType = reader["BillType"].ToString();
                    bill.ReferenceId = reader["ReferenceId"].ToString();
                    BillerList.Add(bill);
                }
            }
            reader.Close();
            //return BillerList;
            string jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(BillerList);
            var json = JToken.Parse(jsonString.ToString());
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(JsonConvert.SerializeObject(json));
            HttpContext.Current.Response.End();
        }

        //[WebMethod]
        //[ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        ////public List<BillerList> AllBillerlist()
        //public void GenerateMiniStatement()
        //{
        //    RetriveMiniStatement("1091100332081", DateTime.Parse("01/20/2024"), DateTime.Parse("01/30/2024"));
            
        //    //return Mini;
        //    string jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(BillerList);
        //    var json = JToken.Parse(jsonString.ToString());
        //    HttpContext.Current.Response.ContentType = "application/json";
        //    HttpContext.Current.Response.Write(JsonConvert.SerializeObject(json));
        //    HttpContext.Current.Response.End();
        //}

        //API for 3rd party to accept request for information (Fetch name)
        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public void AccountInfoRequest(string ServiceCode, string AccountNo, string NameBal,string ExtRefNo, string UserId, string Password)
        {
            int LogId = 0;
            string str = null;
            var jsonString = str ;
            string SavedUserID = null;
            string SavedPassword = null;
            string[] PostStatus = new string[10];
            string ServiceId = null;
            string SourceName = null;
            ResponseMsg msg = new ResponseMsg();
            string EntityName = ServiceCode + "-" + "AccountNo";
            //decimal k = CheckLimit("5037301337461", 30000, "TLBO");
            //Decide whether the request is from Outside or ESB application
            if (ServiceCode.Substring(0, 3) == "ESB")
            {
                ServiceCode = ServiceCode.Substring(3, ServiceCode.Length - 3);
                SavedUserID = GetAPIParameters("ESB", "Post", "UserName");
                SavedPassword = GetAPIParameters("ESB", "Post", "Password");
            }
            else
            {
                SavedUserID = GetAPIParameters(ServiceCode, "Post", "UserName");
                SavedPassword = GetAPIParameters(ServiceCode, "Post", "Password");
            } 
            SourceName = GetAPIParameters(ServiceCode, "Fetch", "SourceName"); //TLB
            ServiceId = GetAPIParameters(ServiceCode, "Post", "ServiceId");
            string methodId = GetAPIParameters(ServiceCode, "Fetch", "MethodId");
            string CBSFetchMethod = GetAPIParameters("FCUBS", "Fetch", "MethodId");
            LogId = RecordLog(Int32.Parse(CBSFetchMethod), "RequestDateTime", "");
            LogId = RecordLog(LogId, "IncomingRequestEntity", EntityName);
            LogId = RecordLog(LogId, "IncomingRequestValue", AccountNo);
            LogId = RecordLog(LogId, "IncomingRequestRefNo", ExtRefNo);
            LogId = RecordLog(LogId, "RequestStatus", "Ok");

            
            CustInfo custInfo = new CustInfo();
            if (String.IsNullOrEmpty(ServiceId) || String.IsNullOrEmpty(SourceName))
            {
                PostStatus[0] = "700";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Service Code";
            } 
            else if (SavedUserID != UserId || SavedPassword != Password)
            {
                PostStatus[0] = "100";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Credentials";
            }
            else
            {
                PostStatus = FetchNameBalFromCBS(ServiceCode, AccountNo, SourceName, NameBal);
            }
            if (PostStatus[0] != "0")
            {
                msg.StatusCode = 100;
                msg.Status = "FAILURE";
                msg.ErrorMsg = PostStatus[1];
                msg.message = PostStatus[2];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(msg);
            }
            else
            {
                custInfo.statusCode = 200;
                custInfo.message = PostStatus[1];
                custInfo.AccountNo = AccountNo;
                custInfo.CustomerData = PostStatus[2];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(custInfo);
            }
            //Record KYC status in ESB database
            //if (PostStatus[0] == "0")
                //LogId = RecordLog(LogId, "ReplyStatus", "KYC Pass");
            LogId = RecordLog(LogId, "Method", methodId);
            LogId = RecordLog(LogId, "ResponseStatus", PostStatus[1]);
            LogId = RecordLog(LogId, "ResponseEntity", AccountNo);
            if (PostStatus[0] != "0")
            {
                LogId = RecordLog(LogId, "Responsevalue", "");
                LogId = RecordLog(LogId, "Description", PostStatus[2]);
            }
            else
                LogId = RecordLog(LogId, "Responsevalue", PostStatus[2]);
            LogId = RecordLog(LogId, "ResponseRefNo", PostStatus[3]);
            //LogId = RecordLog(LogId, "ReplyStatus", "Ok");
            XXX:
            var json = JToken.Parse(jsonString.ToString());

            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(JsonConvert.SerializeObject(json));
            HttpContext.Current.Response.End();
        }

        [WebMethod]
        [ScriptMethod(UseHttpGet = true, ResponseFormat = ResponseFormat.Json)]
        public void ExchangeRateRequest(string ServiceCode, string Currency, string ExtRefNo, string UserId, string Password)
        {
            int LogId = 0;
            string str = null;
            var jsonString = str;
            string SavedUserID = null;
            string SavedPassword = null;
            string[] PostStatus = new string[10];
            string ServiceId = null;
            string SourceName = null;
            ResponseMsg msg = new ResponseMsg();
            string EntityName = ServiceCode + "-" + "AccountNo";
            CurrencyInfo custInfo = new CurrencyInfo();
            Currency = Currency.ToUpper();
            //Decide whether the request is from Outside or ESB application
            if (ServiceCode.Substring(0, 3) == "ESB")
            {
                ServiceCode = ServiceCode.Substring(3, ServiceCode.Length - 3);
                SavedUserID = GetAPIParameters("ESB", "Post", "UserName");
                SavedPassword = GetAPIParameters("ESB", "Post", "Password");
            }
            else
            {
                SavedUserID = GetAPIParameters(ServiceCode, "Post", "UserName");
                SavedPassword = GetAPIParameters(ServiceCode, "Post", "Password");
            }
            SourceName = GetAPIParameters(ServiceCode, "Fetch", "SourceName"); //TLB
            ServiceId = GetAPIParameters(ServiceCode, "Post", "ServiceId");
            string methodId = GetAPIParameters(ServiceCode, "Fetch", "MethodId");
            string CBSFetchMethod = GetAPIParameters("FCUBS", "Fetch", "MethodId");
            LogId = RecordLog(Int32.Parse(CBSFetchMethod), "RequestDateTime", "");
            LogId = RecordLog(LogId, "IncomingRequestEntity", EntityName);
            LogId = RecordLog(LogId, "IncomingRequestValue", Currency);
            LogId = RecordLog(LogId, "IncomingRequestRefNo", ExtRefNo);
            LogId = RecordLog(LogId, "RequestStatus", "Ok");


            if (String.IsNullOrEmpty(ServiceId) || String.IsNullOrEmpty(SourceName))
            {
                PostStatus[0] = "700";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Service Code";
            }
            else if (SavedUserID != UserId || SavedPassword != Password)
            {
                PostStatus[0] = "100";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Credentials";
            }
            else
            {
                PostStatus = FetchExchangeRate(ServiceCode, Currency, "CASH_R");
            }
            if (PostStatus[0] != "0")
            {
                msg.StatusCode = 100;
                msg.Status = "FAILURE";
                msg.ErrorMsg = PostStatus[1];
                msg.message = PostStatus[2];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(msg);
            }
            else
            {
                custInfo.message = PostStatus[1];
                custInfo.Currency = Currency;
                custInfo.Rate = PostStatus[2];
                custInfo.Date = PostStatus[3];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(custInfo);
            }
            //Record KYC status in ESB database
            //if (PostStatus[0] == "0")
            //LogId = RecordLog(LogId, "ReplyStatus", "KYC Pass");
            LogId = RecordLog(LogId, "Method", methodId);
            LogId = RecordLog(LogId, "ResponseStatus", PostStatus[1]);
            LogId = RecordLog(LogId, "ResponseEntity", Currency);
            if (PostStatus[0] != "0")
            {
                LogId = RecordLog(LogId, "Responsevalue", "");
                LogId = RecordLog(LogId, "Description", PostStatus[2]);
            }
            else
                LogId = RecordLog(LogId, "Responsevalue", PostStatus[2]);
            LogId = RecordLog(LogId, "ResponseRefNo", PostStatus[3]);
        //LogId = RecordLog(LogId, "ReplyStatus", "Ok");
        XXX:
            var json = JToken.Parse(jsonString.ToString());

            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.Write(JsonConvert.SerializeObject(json));
            HttpContext.Current.Response.End();
        }

        //API for 3rd party to accept request for tranaction (Post Transaction)
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public void TransactionRequest(string ServiceCode, string AccountNo, string BranchCode, string Amount, string TxnDate, string ExtEntity, string ExtRefNo, string TxnDesc, string UserId, string Password)
        {
            string str = null;
            string OffSetAccNo = null;
            var jsonString = str;
            string SavedUserID = null;
            string SavedPassword = null;
            string SendingTime = null;
            string SourceName = null;
            string ProductName = null;
            string BranchName = null;
            string[] PostStatus = new string[10];
            int LogId = 0;
            string ServiceId = null;
            string EntityName = ServiceCode + "-" + "AccountNo";
            ResponseMsg msg = new ResponseMsg();
            TransactionInfo TxnInfo = new TransactionInfo();
            //Decide whether the request is from Outside or ESB application
            if (ServiceCode.Substring(0, 3) == "ESB")
            {
                ServiceCode = ServiceCode.Substring(3, ServiceCode.Length - 3);
                SavedUserID = GetAPIParameters("ESB", "Post", "UserName");
                SavedPassword = GetAPIParameters("ESB", "Post", "Password");
            }
            else
            {
                SavedUserID = GetAPIParameters(ServiceCode, "Post", "UserName");
                SavedPassword = GetAPIParameters(ServiceCode, "Post", "Password");
            } 
            ServiceId = GetAPIParameters(ServiceCode, "Post", "ServiceId");
            BranchName = GetBranchName(BranchCode);
            string methodId = GetAPIParameters(ServiceCode, "Post", "MethodId");
            if (Check_Duplicate_RefNo(ServiceCode, ExtRefNo) == true)
            {
                PostStatus[0] = "104";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Duplicated Reference Number";
                goto XXX;
            }
            string CBSPostMethod = GetAPIParameters("FCUBS", "Post", "MethodId");
            LogId = RecordLog(Int32.Parse(CBSPostMethod), "RequestDateTime", "");
            LogId = RecordLog(LogId, "IncomingRequestEntity", EntityName);
            LogId = RecordLog(LogId, "IncomingRequestValue", AccountNo);
            LogId = RecordLog(LogId, "IncomingRequestRefNo", ExtRefNo);
            LogId = RecordLog(LogId, "RequestStatus", "Ok");
            //chcek for duplicated reference numebr
            if (String.IsNullOrEmpty(ServiceId))
            {
                PostStatus[0] = "101";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Service Code";
            }
            else if (String.IsNullOrEmpty(BranchName))
            {
                PostStatus[0] = "102";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Branch Code";
            } 
            else if (SavedUserID != UserId || SavedPassword != Password)
            {
                PostStatus[0] = "103";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Credentials";
            }
            else
            {
                SendingTime = DateTime.Now.ToString("yyyyMMddhhmmss");// 2023 02 16 11 08 21
                SourceName = GetAPIParameters(ServiceCode, "Post", "SourceName"); //ECX
                ProductName = GetAPIParameters(ServiceCode, "Post", "ProductName"); //TLBI
                OffSetAccNo = GetAPIParameters(ServiceCode, "Post", "OffSetAccNo");
                if (OffSetAccNo == "OWN_OFFSET")
                    OffSetAccNo = ExtEntity;
                //check the account is valid for transaction
                //PostStatus = FetchNameBalFromCBS(ServiceCode, AccountNo, SourceName, "Name");
                //if (PostStatus[0] != "0")
                    //goto XXX;
                if (GetAPIParameters(ServiceCode, "Post", "ServiceType") == "Debit")
                {
                    string Temp = OffSetAccNo;
                    OffSetAccNo = AccountNo;
                    AccountNo = Temp;
                }
                PostStatus = PostRequestToCBS(OffSetAccNo, ExtEntity, AccountNo, BranchCode, ExtRefNo, SendingTime, Amount, SourceName, ProductName, TxnDesc);
            }
            XXX:
            if (PostStatus[0] != "0")
            {
                msg.StatusCode = Int32.Parse(PostStatus[0]);
                msg.Status= "FAILURE";
                msg.ErrorMsg = PostStatus[1];
                msg.message = PostStatus[2];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(msg);
            }
            else
            {
                TxnInfo.statusCode = 200;
                TxnInfo.message = PostStatus[1];
                TxnInfo.BankRefNo = PostStatus[2];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(TxnInfo);
            }
            LogId = RecordLog(LogId, "ResponseStatus", PostStatus[1]);
            LogId = RecordLog(LogId, "ResponseEntity", AccountNo);
            if (PostStatus[0] != "0")
            {
                LogId = RecordLog(LogId, "Responsevalue", "");
                LogId = RecordLog(LogId, "ResponseRefNo", "");
                LogId = RecordLog(LogId, "Description", PostStatus[2]);
            }
            else
            {
                LogId = RecordLog(LogId, "Responsevalue", Amount);
                LogId = RecordLog(LogId, "ResponseRefNo", PostStatus[2]);
            }
            LogId = RecordLog(LogId, "Method", methodId);
            LogId = RecordLog(LogId, "ReplyStatus", "Ok");

            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.AddHeader("content-length", jsonString.Length.ToString());
            HttpContext.Current.Response.Write(jsonString);
            HttpContext.Current.Response.Flush();
            HttpContext.Current.Response.End();

        }

        //API for 3rd party to accept request for tranaction (Post Transaction)
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public void RevereseTransactionRequest(string ServiceCode, string CBSRefNo, string ExtRefNo, string UserId, string Password)
        {
            string str = null;
            var jsonString = str;
            string SavedUserID = null;
            string SavedPassword = null;
            string SourceName = null;
            string ProductName = null;
            string[] PostStatus = new string[10];
            int LogId = 0;
            string ServiceId = null;
            string AccountNo = null;
            string EntityName = ServiceCode + "-" + "AccountNo";
            ResponseMsg msg = new ResponseMsg();
            TransactionInfo TxnInfo = new TransactionInfo();
            //SourceName = GetAPIParameters("FCUBS", "Reverse", "SourceName");
            PostStatus = FetcAccountNoFromCBS(CBSRefNo, "Debit");
            if (PostStatus[0] == "0")
                AccountNo = PostStatus[2];  
            //get transaction code
            //Decide whether the request is from Outside or ESB application
            if (ServiceCode.Substring(0, 3) == "ESB")
            {
                ServiceCode = ServiceCode.Substring(3, ServiceCode.Length - 3);
                SavedUserID = GetAPIParameters("ESB", "Post", "UserName");
                SavedPassword = GetAPIParameters("ESB", "Post", "Password");
            }
            else
            {
                SavedUserID = GetAPIParameters(ServiceCode, "Post", "UserName");
                SavedPassword = GetAPIParameters(ServiceCode, "Post", "Password");
            }
            //ServiceId = GetAPIParameters(ServiceCode, "Reverse", "ServiceId");
            string methodId = GetAPIParameters("FCUBS", "Reverse", "MethodId");
            LogId = RecordLog(Int32.Parse(methodId), "RequestDateTime", "");
            LogId = RecordLog(LogId, "IncomingRequestEntity", EntityName);
            LogId = RecordLog(LogId, "IncomingRequestValue", CBSRefNo);
            LogId = RecordLog(LogId, "IncomingRequestRefNo", ExtRefNo);
            LogId = RecordLog(LogId, "RequestStatus", "Ok");
            SavedUserID = GetAPIParameters("ESB", "Post", "UserName");
            SavedPassword = GetAPIParameters("ESB", "Post", "Password");
            if (SavedUserID != UserId || SavedPassword != Password)
            {
                PostStatus[0] = "105";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Credentials";
            }
            else if (String.IsNullOrEmpty(AccountNo))
            {
                PostStatus[0] = "106";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Account/Transaction";
            }
            else
            {
                SourceName = GetAPIParameters("FCUBS", "Reverse", "SourceName"); //ECX
                ProductName = GetAPIParameters("FCUBS", "Post", "ProductName"); //TLBI
                PostStatus = RevereseCBSTransaction(CBSRefNo,SourceName, ProductName);
            }
            if (PostStatus[0] != "0")
            {
                msg.StatusCode = Int32.Parse(PostStatus[0]); ;
                msg.Status = "FAILURE";
                msg.ErrorMsg = PostStatus[1];
                msg.message = PostStatus[2];
                //JavaScriptSerializer js = new JavaScriptSerializer();
                //Context.Response.Write(js.Serialize(msg));
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(msg);
            }
            else
            {
                TxnInfo.statusCode = 200;
                TxnInfo.message = PostStatus[1];
                TxnInfo.BankRefNo = PostStatus[2];
                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(TxnInfo);
            }
            LogId = RecordLog(LogId, "ResponseStatus", PostStatus[1]);
            LogId = RecordLog(LogId, "ResponseEntity", CBSRefNo);
            if (PostStatus[0] != "0")
            {
                LogId = RecordLog(LogId, "Responsevalue", "");
                LogId = RecordLog(LogId, "Description", PostStatus[2]);
            }
            else
                LogId = RecordLog(LogId, "Responsevalue", AccountNo);
            LogId = RecordLog(LogId, "ResponseRefNo", PostStatus[3]);
            LogId = RecordLog(LogId, "ReplyStatus", "Ok");

            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.ContentType = "application/json";
            HttpContext.Current.Response.AddHeader("content-length", jsonString.Length.ToString());
            HttpContext.Current.Response.Write(jsonString);
            HttpContext.Current.Response.Flush();
            HttpContext.Current.Response.End();
        }

        public string[] FetchNameBalFromCBS(string ServiceCode, string BankAccountNo, string SourceName, string RequestType)
        {
            //string x = GetAccountNo("109TLBI231860051");
            string txnType = GetAPIParameters(ServiceCode, "Post", "ServiceType");
            string[] PostStatus = new string[10];
            RequestType = RequestType.ToUpper();
            string CustName = null;
            decimal CustBal = (decimal)0.00;
            string Currency = null;
            string RefNo = null;
            string AccountCategaory = null;
            string OperationName = null;
            string url = null;
            SourceName = "TLB";
            //if the account is GL
            RequestType = RequestType.ToUpper();
            if (BankAccountNo.Count() == 7 && RequestType == "NAME")
            {
                string AccName = Get_GL(BankAccountNo);
                if (AccName == null)
                {
                    PostStatus[0] = "-1";
                    PostStatus[1] = "FAILURE";
                    PostStatus[2] = "Invalid Request Type";
                }
                else
                {
                    PostStatus[0] = "0";
                    PostStatus[1] = "SUCCESS";
                    PostStatus[2] = AccName + " (GL)";
                }
                goto XXX;
            }
            //First Check for KYC
            string[] CustInfo = new string[12];
            //CustInfo = GetFullCustomerInfoFromCBS(ServiceCode, BankAccountNo, SourceName);
            //if (CustInfo[12] == "F")
            //{
            //    PostStatus[0] = "-1";
            //    PostStatus[1] = "FAILURE";
            //    PostStatus[2] = "KYC is Failed.";
            //    goto XXX;
            //} 
            if (String.IsNullOrEmpty(BankAccountNo))
            {
                PostStatus[0] = "-1";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Account Number";
                goto XXX;
            }
            
            string BranchCode = BankAccountNo.Substring(0,3);
            AccountCategaory = BankAccountNo.Substring(3,2);
            HttpWebRequest request = null;
            XmlDocument SOAPReqBody = new XmlDocument();
            if (AccountCategaory == "01" || AccountCategaory == "02" || AccountCategaory == "03" || AccountCategaory == "04" || AccountCategaory == "05" || AccountCategaory == "06" || AccountCategaory == "07" || AccountCategaory == "08")
            {
                url = GetAPIParameters("IFB", "Fetch", "URL");
                request = (HttpWebRequest)WebRequest.Create(@url);
                request.Headers.Add(@"SOAP:Action");
                request.ContentType = "text/xml;charset=\"utf-8\"";
                request.Accept = "text/xml";
                request.Method = "POST";
                //<fcub:USERID>ABELMT</fcub:USERID>  //Test
                //<fcub:USERID>TELEBIRRBR</fcub:USERID>  //Prod
                SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSIAService"">
                   <soapenv:Header/> 
                   <soapenv:Body> 
                      <fcub:QUERYIACUSTACC_IOFS_REQ> 
                         <fcub:FCUBS_HEADER> 
                            <fcub:SOURCE>" + SourceName + @"</fcub:SOURCE> 
                            <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP> 
                            <fcub:USERID>TELEBIRR</fcub:USERID> 
                            <fcub:BRANCH>" + BranchCode + @"</fcub:BRANCH> 
                            <!--Optional:--> 
                            <fcub:MODULEID>AC</fcub:MODULEID> 
                            <fcub:SERVICE>FCUBSIAService</fcub:SERVICE> 
                            <fcub:OPERATION>QueryIACustAcc</fcub:OPERATION> 
                            <!--Optional:--> 
                            <fcub:SOURCE_OPERATION>QueryIACustAcc</fcub:SOURCE_OPERATION> 
                            <!--Optional:--> 
                            <fcub:SOURCE_USERID>TELEBIRR</fcub:SOURCE_USERID> 
                         </fcub:FCUBS_HEADER> 
                         <fcub:FCUBS_BODY> 
                            <fcub:Cust-Account-IO> 
                               <fcub:BRN>" + BranchCode + @"</fcub:BRN> 
                               <fcub:ACC>" + BankAccountNo + @"</fcub:ACC>                 
                            </fcub:Cust-Account-IO> 
                         </fcub:FCUBS_BODY> 
                      </fcub:QUERYIACUSTACC_IOFS_REQ> 
                   </soapenv:Body> 
                </soapenv:Envelope>");
            }
            else
            {
                url = GetAPIParameters("FCUBS", "Fetch", "URL");
                request = (HttpWebRequest)WebRequest.Create(@url);
                request.Headers.Add(@"SOAP:Action");
                request.ContentType = "text/xml;charset=\"utf-8\"";
                request.Accept = "text/xml";
                request.Method = "POST";
                //<fcub:USERID>ABELMT</fcub:USERID>  //Test
                //<fcub:USERID>TELEBIRRBR</fcub:USERID>  //Prod
                SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSAccService""> 
               <soapenv:Header/> 
               <soapenv:Body> 
                  <fcub:QUERYCUSTACC_IOFS_REQ> 
                     <fcub:FCUBS_HEADER> 
                        <fcub:SOURCE>" + SourceName + @"</fcub:SOURCE> 
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP> 
                        <fcub:USERID>ESBUSER</fcub:USERID> 
                        <fcub:BRANCH>" + BranchCode + @"</fcub:BRANCH>
                        <!--Optional:--> 
                        <fcub:MODULEID>AC</fcub:MODULEID> 
                        <fcub:SERVICE>FCUBSAccService</fcub:SERVICE> 
                        <fcub:OPERATION>QueryCustAcc</fcub:OPERATION> 
                        <!--Optional:--> 
                        <fcub:SOURCE_OPERATION>QueryCustAcc</fcub:SOURCE_OPERATION> 
                        <!--Optional:--> 
                        <fcub:SOURCE_USERID>ESBUSER</fcub:SOURCE_USERID> 
                     </fcub:FCUBS_HEADER> 
                     <fcub:FCUBS_BODY> 
                        <fcub:Cust-Account-IO> 
                           <fcub:BRN>" + BranchCode + @"</fcub:BRN> 
                           <fcub:ACC>" + BankAccountNo + @"</fcub:ACC> 
                        </fcub:Cust-Account-IO> 
                     </fcub:FCUBS_BODY> 
                  </fcub:QUERYCUSTACC_IOFS_REQ> 
               </soapenv:Body> 
            </soapenv:Envelope>");
            }     

            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                PostStatus[0] = "-1";
                PostStatus[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();//<SPL_AC_GEN
                    int index = GetIndex("<Summary>", ServiceResult);
                    string Frozen = ExtractData(index, "<FROZEN", ">", "</FROZEN>", ServiceResult); //FROZEN
                    string Dormant = ExtractData(index, "<DORM", ">", "</DORM>", ServiceResult); //DORMANT
                    string NoDebit = ExtractData(0, "<ACSTATNODR", ">", "</ACSTATNODR>", ServiceResult); //No Debit
                    string NoCredit = ExtractData(0, "<ACSTATNOCR", ">", "</ACSTATNOCR>", ServiceResult); //No Credit
                    CustName = ExtractData(0, "<CUSTNAME", ">", "</CUSTNAME>", ServiceResult); //Customer Name
                    Currency = ExtractData(0, "<CCY", ">", "</CCY>", ServiceResult); //Account currency type
                    RefNo = ExtractData(0, "<MSGID", ">", "</MSGID>", ServiceResult); //CBS reference numeber
                    if (txnType == "Debit" && NoDebit == "Y")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Account is No Debit Status";
                        PostStatus[3] = RefNo;
                    }
                    else if (txnType == "Credit" && NoCredit == "Y")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Account is No Credit Status";
                        PostStatus[3] = RefNo;
                    }
                    else if (Frozen == "Y")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Account is Frozen";
                        PostStatus[3] = RefNo;
                    }
                    else if (Dormant == "Y")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Account is Dormant";
                        PostStatus[3] = RefNo;
                    }
                    else if (CustName == null)
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Account is not Found";
                        PostStatus[3] = RefNo;
                    }
                    else if (Currency != "ETB" && BankAccountNo != "1092210715371")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Account Currency is not ETB";
                        PostStatus[3] = RefNo;
                    }
                    else
                    {
                        CustBal = decimal.Parse(ExtractData(0, "<ACY_AVL_BAL", ">", "</ACY_AVL_BAL>", ServiceResult));
                        PostStatus[0] = "0";
                        PostStatus[1] = "SUCCESS";
                        PostStatus[3] = RefNo;
                        if(RequestType == "NAME")
                            PostStatus[2] = CustName;
                        else if (RequestType == "BAL")
                            PostStatus[2] = CustBal.ToString();
                        else if (RequestType.All(char.IsDigit))
                        {
                            if (CustBal >= decimal.Parse(RequestType))
                                PostStatus[2] = "Sufficient";
                            else
                                PostStatus[2] = "Insufficient";
                        }
                        else
                        {
                            PostStatus[0] = "-1";
                            PostStatus[1] = "FAILURE";
                            PostStatus[2] = "Invalid Request Type";
                            PostStatus[3] = RefNo;
                        }
                    }
                        
                }
            }
        XXX:
            return PostStatus;
        }

        public string[] FetchExchangeRate(string ServiceCode, string Currency, string RateType)
        {
            //string x = GetAccountNo("109TLBI231860051");
            string txnType = GetAPIParameters(ServiceCode, "Post", "ServiceType");
            string[] PostStatus = new string[10];
            //string url = "http://10.1.200.153:7003/FCUBSCcyService/FCUBSCcyService";
            if (String.IsNullOrEmpty(Currency))
            {
                PostStatus[0] = "-1";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Request";
                goto XXX;
            }

            HttpWebRequest request = null;
            XmlDocument SOAPReqBody = new XmlDocument();
            string url = GetAPIParameters("ESB", "Rate", "URL");
            request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSCcyService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:QUERYCYDRATEE_IOFS_REQ>
                     <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>VTM</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP> 
                        <fcub:USERID>ESBUSER</fcub:USERID>   
                        <fcub:BRANCH>000</fcub:BRANCH>  
                        <fcub:SERVICE>FCUBSCcyService</fcub:SERVICE>
                        <fcub:OPERATION>QueryCYDRATEE</fcub:OPERATION>
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Ccy-Rate-Master-IO>
                           <!--Optional:-->
                           <fcub:BRNCD>000</fcub:BRNCD>
                           <fcub:CCY1>" + Currency + @"</fcub:CCY1>
                           <fcub:CCY2>ETB</fcub:CCY2>
                        </fcub:Ccy-Rate-Master-IO>
                     </fcub:FCUBS_BODY>
                  </fcub:QUERYCYDRATEE_IOFS_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");

            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                PostStatus[0] = "-1";
                PostStatus[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();//<SPL_AC_GEN
                    string ReqStatus = ExtractData(0, "<MSGSTAT", ">", "</MSGSTAT>", ServiceResult); //FROZEN
                    if (ReqStatus != "SUCCESS")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Error Retriving Exchange Rate";
                        PostStatus[3] = "";
                    }
                    else
                    {
                        int index = GetIndex(RateType, ServiceResult);
                        if(index != 0)
                        {
                            decimal MidRate = decimal.Parse(ExtractData(index, "<MIDRATE", ">", "</MIDRATE>", ServiceResult));
                            decimal BUYRATE = decimal.Parse(ExtractData(index, "<BUYRATE", ">", "</BUYRATE>", ServiceResult));
                            decimal SALERATE = decimal.Parse(ExtractData(index, "<SALERATE", ">", "</SALERATE>", ServiceResult));
                            string RATEDATE = ExtractData(index, "<RATEDATE", ">", "</RATEDATE>", ServiceResult);
                            PostStatus[0] = "0";
                            PostStatus[1] = "SUCCESS";
                            PostStatus[2] = BUYRATE.ToString();
                            PostStatus[3] = RATEDATE;
                        }
                        else
                        {
                            PostStatus[0] = "-1";
                            PostStatus[1] = "FAILURE";
                            PostStatus[2] = "Invalid Request Rate";
                            PostStatus[3] = "";
                        }
                    }

                }
            }
        XXX:
            return PostStatus;
        }

        public string[] FetcAccountNoFromCBS(string BankRefNo, string TxnType)
        {
            string[] PostStatus = new string[10];
            string ResponseStatus = null;
            decimal CustBal = (decimal)0.00;
            if (String.IsNullOrEmpty(BankRefNo))
            {
                PostStatus[0] = "-1";
                PostStatus[1] = "FAILURE";
                PostStatus[2] = "Invalid Account Number";
                goto XXX;
            }
            string url = GetAPIParameters("FCUBS", "Post", "URL");
            string SourceName = "USSD";  // GetAPIParameters("FCUBS", "Reverse", "SourceName");

            //string url = "http://10.1.200.153:7003/FCUBSAccService/FCUBSAccService?wsdl";
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            //<fcub:USERID>TELEBIRR</fcub:USERID>   //Test
            //<fcub:USERID>TELEBIRRBR</fcub:USERID>   //Prod
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSRTService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:QUERYTRANSACTION_IOFS_REQ>
                       <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>" + SourceName + @"</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>
                        <fcub:USERID>ESBUSER</fcub:USERID>
                        <fcub:BRANCH>000</fcub:BRANCH>
                        <fcub:MODULEID>AC</fcub:MODULEID>
                        <fcub:SERVICE>FCUBSRTService</fcub:SERVICE>
                        <fcub:OPERATION>QueryTransaction</fcub:OPERATION>
                        <!--Optional:-->
                        <fcub:SOURCE_OPERATION>QueryTransaction</fcub:SOURCE_OPERATION>      
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Transaction-Details-IO>
                           <!--Optional:-->
                           <fcub:XREF>" + BankRefNo + @"</fcub:XREF>
                        </fcub:Transaction-Details-IO>
                     </fcub:FCUBS_BODY>
                  </fcub:QUERYTRANSACTION_IOFS_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");
            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                PostStatus[0] = "-1";
                PostStatus[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    ResponseStatus = ExtractData(0, "<MSGSTAT", ">", "</MSGSTAT>", ServiceResult); 
                    if (ResponseStatus == null || ResponseStatus == "FAILURE")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[1] = "FAILURE";
                        PostStatus[2] = "Transaction is not Found";
                    }
                    else
                    {
                        PostStatus[0] = "0";
                        PostStatus[1] = "SUCCESS";
                        if (TxnType == "Debit")
                            PostStatus[2] = ExtractData(0, "<TXNACC", ">", "</TXNACC>", ServiceResult);
                        else
                            PostStatus[2] = ExtractData(0, "<OFFSETACC", ">", "</OFFSETACC>", ServiceResult);
                    }

                }
            }
        XXX:
            return PostStatus;
        }

        public string CheckKYC(string CustomerId)
        {
            string KYC_Status = null;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            //string methodIdCon = GetAPIParameters("FCUBS", "Fetch", "MethodId");
            //string methodIdIFB = GetAPIParameters("IFB", "Fetch", "MethodId");
            //Check whether verified previously
            com = new SqlCommand("SELECT * FROM [dbo].[TxnLog] WHERE IncomingRequestValue = '" + CustomerId + "' AND ReplyStatus = 'KYC Pass'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Close();
                return "KYC Pass";
            }
            reader.Close();
            return KYC_Status;
        }

        public string[] GetFullCustomerInfoFromCBS(string ServiceCode, string BankAccountNo, string SourceName)
        {
            string KYC = null;
            string ProductName = "TLB"; //
            string BranchCode = BankAccountNo.Substring(0, 3);
            string ProductCode = BankAccountNo.Substring(3, 2);
            string CustomerId = BankAccountNo.Substring(5, 7);
            string[] CustInfo = new string[20];
            //First check KYC from ESB database
            KYC = CheckKYC(BankAccountNo);
            if (KYC == "KYC Pass")
            {
                CustInfo[12] = "V";
                goto XXX;
            }
            //extract the xml
            //string url = "http://10.1.200.201:7003/FCUBSCustomerService/FCUBSCustomerService";
            string url = GetAPIParameters("FCUBS", "CIF", "URL");
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";

            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSCustomerService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:QUERYCUSTOMER_IOFS_REQ>
                     <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>" + ProductName + @"</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>
                        <fcub:USERID>ESBUSER</fcub:USERID>
                        <fcub:BRANCH>000</fcub:BRANCH>
                        <fcub:SERVICE>FCUBSCustomerService</fcub:SERVICE>
                        <fcub:OPERATION>QueryCustomer</fcub:OPERATION>
                        <fcub:ACTION>VIEW</fcub:ACTION>
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Customer-IO>
                           <fcub:CUSTNO>" + CustomerId + @"</fcub:CUSTNO>
                        </fcub:Customer-IO>
                     </fcub:FCUBS_BODY>
                  </fcub:QUERYCUSTOMER_IOFS_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");
            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                CustInfo[0] = "0";
                CustInfo[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    CustInfo[1] = ExtractData(0, "<FSTNAME", ">", "</FSTNAME>", ServiceResult); //FirstName
                    //CustInfo[2] = ExtractData(0, "<MIDNAME", ">", "</MIDNAME>", ServiceResult); //MiddleName
                    //CustInfo[3] = ExtractData(0, "<LSTNAME", ">", "</LSTNAME>", ServiceResult); //LastName
                    //CustInfo[4] = ExtractData(0, "<GENDR", ">", "</GENDR>", ServiceResult); //Gender
                    //CustInfo[5] = ExtractData(0, "<MARITALSTAT", ">", "</MARITALSTAT>", ServiceResult); //MarritalStatus
                    //CustInfo[6] = ExtractData(0, "<ADDRLN1", ">", "</ADDRLN1>", ServiceResult); //City
                    //CustInfo[7] = ExtractData(0, "<ADDRLN2", ">", "</ADDRLN2>", ServiceResult); //Subcity
                    //CustInfo[8] = ExtractData(0, "<ADDRLN3", ">", "</ADDRLN3>", ServiceResult); //Wereda
                    //CustInfo[9] = ExtractData(0, "<MOBNUM", ">", "</MOBNUM>", ServiceResult); //MobileNo
                    //CustInfo[10] = ExtractData(0, "<UIDVAL", ">", "</UIDVAL>", ServiceResult); //IdNumber
                    CustInfo[12] = ExtractData(0, "<KYCSTAT", ">", "</KYCSTAT>", ServiceResult); //KYC
                    //if (CustInfo[5] == "M")
                    //    CustInfo[5] = "Married";
                    //else
                    //    CustInfo[5] = "Single";
                    //if (CustInfo[4] == "M")
                    //    CustInfo[4] = "Male";
                    //else
                    //    CustInfo[4] = "Female";
                    //if (ProductCode == "21")
                    //    CustInfo[11] = "Current";
                    //else
                    //    CustInfo[11] = "Saving";
                    if (String.IsNullOrEmpty(CustInfo[1]))
                    {
                        CustInfo[0] = "0";
                    }
                    else
                    {
                        CustInfo[0] = "1";
                    }

                }
            }
        XXX:
            return CustInfo;
        }
        

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        //public void BillTxnRequest(string manifest_id, string bill_id, string amount, string paid_dt, string payee_mobile, string paid_at, string txn_code)
        public void BillTxnRequest()
        {
            string api_key = null;
            string api_secret = null;
            string bill_id = null;
            string biller_id = null;
            var jsonString = api_secret;
            HttpRequest Request = HttpContext.Current.Request;
            BillPayData TxnData = null;
            string contentType = HttpContext.Current.Request.ContentType;
            string MsgMethod = HttpContext.Current.Request.HttpMethod;
            if (MsgMethod == "GET")
            {
                api_key = HttpContext.Current.Request.Headers.Get("api_secret");
                api_secret = HttpContext.Current.Request.Headers.Get("api_key");
                biller_id = HttpContext.Current.Request.Params.Get("biller_id");
                bill_id = HttpContext.Current.Request.Params.Get("bill_id");
                Bill_Data billData = BillDetail(biller_id, bill_id);

                jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(billData);

                if (billData.manifest_id == null)
                {
                    ResponseMsg msg = new ResponseMsg();
                    if (billData.bill_id != null)
                    {
                        msg.StatusCode = Int32.Parse(ExtractData(0, ":", "(", ")", billData.bill_desc));
                        msg.Status = "FAILURE";
                        msg.ErrorMsg = ExtractData(0, ")", " ", ".", billData.bill_desc);
                    }
                    else
                    {
                        msg.StatusCode = 999;
                        msg.Status = "FAILURE";
                        msg.ErrorMsg = "No Connection with server";
                    }

                    if (msg.StatusCode == 400)
                        msg.message = "Partial payment is not allowed. Customer should pay the full amount";
                    if (msg.StatusCode == 402)
                        msg.message = "Bill already paid!";
                    else if (msg.StatusCode == 404)
                        msg.message = "Customer bill not found";
                    else if (msg.StatusCode == 422)
                        msg.message = "Unknown manifest Id";
                    else if (msg.StatusCode == 500)
                        msg.message = "Server not available";
                    else if (msg.StatusCode == 999)
                        msg.message = "Connection Refused";
                    else
                        msg.message = "Bad request";

                    jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(msg);
                }
                var json = JToken.Parse(jsonString.ToString());

                HttpContext.Current.Response.ContentType = "application/json";
                HttpContext.Current.Response.Write(JsonConvert.SerializeObject(json));
                HttpContext.Current.Response.End();
            }
            else //MsgMethod == "POST"
            {
                using (System.IO.Stream stream = HttpContext.Current.Request.InputStream)
                using (System.IO.StreamReader reader = new System.IO.StreamReader(stream))
                {
                    stream.Seek(0, System.IO.SeekOrigin.Begin);

                    string bodyText = reader.ReadToEnd(); bodyText = bodyText == "" ? "{}" : bodyText;

                    var json = Newtonsoft.Json.Linq.JObject.Parse(bodyText);

                    TxnData = Newtonsoft.Json.JsonConvert.DeserializeObject<BillPayData>(json.ToString());
                }
                
                SuccessMsg SucMsg = new SuccessMsg(); 
                ResponseMsg Msg = new ResponseMsg();
                //TxnData.manifest_id = "1234567";
                //TxnData.bill_id = "2400000001";
                Msg = PayBill(TxnData.manifest_id, TxnData.txn_code, TxnData.bill_id, TxnData.amount, TxnData.paid_dt, TxnData.payee_mobile, TxnData.paid_at, null, null);
                JavaScriptSerializer js = new JavaScriptSerializer();
                if (Msg.StatusCode == 200)
                {
                    SucMsg.ResponseCode = 200;
                    SucMsg.confirmation_code = Msg.message;
                    //Context.Response.Write(js.Serialize(SucMsg));
                    jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(SucMsg);
                }
                else
                {
                    //Context.Response.Write(js.Serialize(Msg));
                    jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(Msg);
                }
                var returnjson = JToken.Parse(jsonString.ToString());
                HttpContext.Current.Response.Clear();
                HttpContext.Current.Response.ContentType = "application/json";
                HttpContext.Current.Response.AddHeader("content-length", jsonString.Length.ToString());
                HttpContext.Current.Response.Write(JsonConvert.SerializeObject(returnjson));
                HttpContext.Current.Response.Flush();
                HttpContext.Current.Response.End();
            }
        }

        public Bill_Data BillDetail(string Biller, string Bill)
        {
            string ServiceCode = null;
            Bill_Data billdata = new Bill_Data();
            int LogId = 0;
            string json = null;
            //Biller Blr = db.Billers.Where(s => s.BillerId == Biller).FirstOrDefault();
            //if (Blr == null)
            //{
                //billdata.bill_desc = "Invalid Biller";
                //LogId = RecordLog(LogId, "ResponseStatus", "Failed");
                //goto XXX;
            //}
            //int API = Blr.ThirdParty;
            //ServiceCode = db.Services.Where(s => s.ThirdParty == API && s.ServiceType == "Debit").FirstOrDefault().ServiceCode;
            //int Biller_Id = Blr.BId;
            //ServiceCode = db.Services.Where(s => s.Biller == Biller_Id).FirstOrDefault().ServiceCode;
            ServiceCode = Biller;
            //string ThirdPartyName = db.ThirdParties.Find(API).CompanyAbr;
            //APIMethod method = db.APIMethods.Where(s => s.Service1.ThirdParty == API && s.MethodName == "Fetch").FirstOrDefault();
            if (String.IsNullOrEmpty(ServiceCode))
            {
                billdata.bill_desc = "Invalid Biller";
                //LogId = RecordLog(LogId, "ResponseStatus", "Failed");
                goto XXX;
            }
            string methodId = GetAPIParameters(ServiceCode, "Fetch", "MethodId");
            string api_key = GetAPIParameters(ServiceCode, "Fetch", "UserName");
            string api_secret = GetAPIParameters(ServiceCode, "Fetch", "Password");
            string url = GetAPIParameters(ServiceCode, "Fetch", "URL");
            string EntityName = GetAPIParameters(ServiceCode, "Post", "Description");
            LogId = RecordLog(Int32.Parse(methodId), "RequestDateTime", "");
            LogId = RecordLog(LogId, "IncomingRequestEntity", EntityName);
            LogId = RecordLog(LogId, "IncomingRequestvalue", Bill);
            LogId = RecordLog(LogId, "RequestStatus", "OK");

            url = string.Format(url, Biller, Bill);
            try
            {
                if (ServiceCode == "DRS")
                    billdata = Dearsh_Fetch_API(Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "GUGO")
                    billdata = GuzoGo_Fetch_API(Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "TLBO")
                    billdata = TeleBirr_Fetch_API(Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "TLBM")
                    billdata = TeleBirr_Fetch_Merchant_API(Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "NDJO")
                    billdata = Nedaj_Fetch_API(Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "KCHO")
                    billdata = Kacha_Fetch_API(Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "SCHF")
                    billdata = SchoolFee_Fetch_API(Biller, Bill, api_key, api_secret, url);
                //else if (ServiceCode == "EWTO")
                    //billdata = EWallet_Fetch_API(Biller, Bill, api_key, api_secret, url);
                LogId = RecordLog(LogId, "ResponseStatus", "SUCCESS");
                LogId = RecordLog(LogId, "ResponseEntity", billdata.bill_id);
                LogId = RecordLog(LogId, "Responsevalue", billdata.name);
                LogId = RecordLog(LogId, "ResponseRefNo", billdata.manifest_id);
                LogId = RecordLog(LogId, "ReplyStatus", "Ok");
            }
            catch (WebException ex)
            {
                // generic error handling
                billdata.bill_desc = ex.Message.ToString();
                LogId = RecordLog(LogId, "ResponseStatus", "Failed");
            }
        XXX:
            return billdata;
        }

        public ResponseMsg PayBill(string Biller, string RefNo, string Bill, string amount, string paid_dt, string payee_mobile, string paid_at, string CmpName, string TinNo)
        {
            ResponseMsg Msg = new ResponseMsg();
            string ServiceCode = null;
            int LogId = 0;
            int BillerId = 0;
            int NonDRS = Biller.IndexOf("NonDRS_");
            if (NonDRS == 0)
            {
                ServiceCode = Biller.Substring(7);
                //Biller Blr = db.Billers.Where(s => s.BillerId == Biller).FirstOrDefault();
                //if (Blr == null)
                //{
                //    Msg.StatusCode = 107;
                //    Msg.Status = "FAILURE";
                //    Msg.ErrorMsg = "Invalid Biller.";
                //    Msg.message = "Biller is not registered.";
                //    goto XXX;
                //}
                //BillerId = Blr.BId;
            }
            //ServiceCode = db.Services.Where(s => s.Biller == BillerId).FirstOrDefault().ServiceCode;
            if (String.IsNullOrEmpty(ServiceCode))
            {
                Msg.StatusCode = 108;
                Msg.Status = "FAILURE";
                Msg.ErrorMsg = "Invalid Service Code.";
                Msg.message = "Biller is not registered.";
                LogId = RecordLog(LogId, "ResponseStatus", "Failed");
                goto XXX;
            }

            string methodId = GetAPIParameters(ServiceCode, "Post", "MethodId");
            string api_key = GetAPIParameters(ServiceCode, "Post", "UserName");
            string api_secret = GetAPIParameters(ServiceCode, "Post", "Password");
            string url = GetAPIParameters(ServiceCode, "Post", "URL");
            string EntityName = GetAPIParameters(ServiceCode, "Post", "Description");
            LogId = RecordLog(Int32.Parse(methodId), "RequestDateTime", "");
            LogId = RecordLog(LogId, "IncomingRequestEntity", EntityName);
            LogId = RecordLog(LogId, "IncomingRequestvalue", Bill);
            LogId = RecordLog(LogId, "IncomingRequestRefNo", RefNo);
            LogId = RecordLog(LogId, "RequestStatus", "OK");
            try
            {
                if (ServiceCode == "DRS")
                    Msg = Dearsh_Payment_API(RefNo, amount, paid_dt, payee_mobile, paid_at,  Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "GUGO")
                    Msg = GuzoGo_Payment_API(RefNo, amount, paid_dt, payee_mobile, paid_at,  Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "TLBO")
                    Msg = TeleBirr_Payment_API(RefNo, amount, paid_dt, payee_mobile, paid_at,  Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "TLBM")
                    Msg = TeleBirr_Payment_Merchant__API(RefNo, amount, paid_dt, payee_mobile, paid_at, Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "NDJO")
                    Msg = Nedaj_Link_API(RefNo, amount, paid_dt, payee_mobile, paid_at,  Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "KCHO")
                    Msg = Kacha_Transfer_API(RefNo, amount, paid_dt, payee_mobile, paid_at, Biller, Bill, api_key, api_secret, url);
                else if (ServiceCode == "SCHF")
                    Msg = SchoolFee_Payment_API(RefNo, amount, paid_dt, payee_mobile, paid_at, Biller, Bill, api_key, api_secret, url);
                LogId = RecordLog(LogId, "ResponseStatus", Msg.Status);
                LogId = RecordLog(LogId, "ResponseEntity", Bill);
                LogId = RecordLog(LogId, "Responsevalue", amount.ToString());
                LogId = RecordLog(LogId, "ResponseRefNo", Msg.message);
                LogId = RecordLog(LogId, "ReplyStatus", "Ok");
            }
            catch (WebException ex)
            {
                Msg.StatusCode = 109;
                Msg.Status = "FAILURE";
                Msg.ErrorMsg = "Transaction Failed";
                Msg.message = "Transaction Failed";
                LogId = RecordLog(LogId, "ResponseStatus", "Failed");
            }        
        XXX:
            return Msg;
        }

        public string[] PostToCBS(string SendingIdentityID, string BankAccountNo, string OrderId, string SendingTime, string Amount, string SourceName, string ProdName)
        {
            string MSGID = "TLB" + DateTime.Now.ToString("yyyyMMddhhmmss");
            string BranchCode = BankAccountNo.Substring(0, 3);
            string OffSetAccNo = GetOffSetAccountNo("TLBR");//"1045440"
            string OffSetBranchCode = "000";
            string Narrative = "Fund Transfer from TeleBirr Mobile " + SendingIdentityID + " to the Account.";
            string []PostStatus = new string[10];
            string ResponseDesc = null;
            string CBSRefNo = null;
            //get url
            Service ServiceName = db.Services.Where(s => s.ServiceCode == "TLBR").FirstOrDefault();
            APIMethod method = db.APIMethods.Where(s => s.Service == ServiceName.ServiceId && s.MethodName == "Post").FirstOrDefault();
            string url = method.URL;
            //string url = "http://10.1.200.153:7003/FCUBSRTService/FCUBSRTService?wsdl";
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";

            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSRTService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:CREATETRANSACTION_FSFS_REQ>
                     <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>" + SourceName + @"</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>
                        <fcub:MSGID>" + OrderId + @"</fcub:MSGID>
                        <fcub:USERID>TELEBIR</fcub:USERID>
                        <fcub:BRANCH>000</fcub:BRANCH>
                        <fcub:MODULEID>RT</fcub:MODULEID>
                        <fcub:SERVICE>FCUBSRTService</fcub:SERVICE>
                        <fcub:OPERATION>CreateTransaction</fcub:OPERATION>
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Transaction-Details>
                           <fcub:PRD>" + ProdName + @"</fcub:PRD>
                           <fcub:BRN>" + BranchCode + @"</fcub:BRN>
                           <fcub:TXNBRN>" + OffSetBranchCode + @"</fcub:TXNBRN>
                           <fcub:TXNACC>" + OffSetAccNo + @"</fcub:TXNACC>
                           <fcub:TXNCCY>ETB</fcub:TXNCCY>
                           <fcub:TXNAMT>" + Amount + @"</fcub:TXNAMT>               
                           <fcub:OFFSETBRN>" + BranchCode + @"</fcub:OFFSETBRN>
                           <fcub:OFFSETACC>" + BankAccountNo + @"</fcub:OFFSETACC>
                           <fcub:OFFSETCCY>ETB</fcub:OFFSETCCY>     
                           <fcub:NARRATIVE>" + Narrative + @"</fcub:NARRATIVE>               
                        </fcub:Transaction-Details>
                     </fcub:FCUBS_BODY>
                  </fcub:CREATETRANSACTION_FSFS_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");
            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                PostStatus[0] = "1";
                PostStatus[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    PostStatus[1] = ExtractData(0, "<MSGSTAT", ">", "</MSGSTAT>", ServiceResult); //Code
                    ResponseDesc = ExtractData(0, "<EDESC", ">", "</EDESC>", ServiceResult); //Description
                    CBSRefNo = ExtractData(0, "<XREF", ">", "</XREF>", ServiceResult); //Description
                    if (PostStatus[1] == "FAILURE")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[2] = ResponseDesc;
                    }
                    else
                    {
                        PostStatus[0] = "0";
                        PostStatus[1] = "SUCCESS";
                        PostStatus[2] = CBSRefNo;
                    }
                }
            }
        XXX:
            return PostStatus;
        }

        public string[] PostRequestToCBS(string DrBankAccountNo, string SendingIdentityID, string CrBankAccountNo, string BranchCode, string OrderId, string SendingTime, string Amount, string SourceName, string ProdName, string TxnDesc)
        {
            string DrBranchCode = null;
            string OffSetBranchCode = null;
            string MSGID = OrderId; // ProdName + DateTime.Now.ToString("yyyyMMddhhmmss");
            string DrCurrency = "ETB";
            string CrCurrency = "ETB";
            //debit account
            if (DrBankAccountNo.Length == 10)
            {
                DrBranchCode = DrBankAccountNo.Substring(0, 3); 
                DrBankAccountNo = DrBankAccountNo.Substring(3, DrBankAccountNo.Length - 3);
            }
            else if (DrBankAccountNo.Length == 13)
            {
                DrBranchCode = DrBankAccountNo.Substring(0, 3);
            }
            else
                DrBranchCode = "000";
            //credit account
            if (CrBankAccountNo.Length == 10)
            {
                OffSetBranchCode = CrBankAccountNo.Substring(0, 3);
                CrBankAccountNo = CrBankAccountNo.Substring(3, CrBankAccountNo.Length - 3);
            }
            else if (CrBankAccountNo.Length == 13)
                OffSetBranchCode = CrBankAccountNo.Substring(0, 3);
            else
                OffSetBranchCode = "000";
            //this code amended to skip the telebirr limitation for via branch
            if (ProdName == "TLBB" && DrBankAccountNo.Length == 7)
            {
                ProdName = "TLBR";
                DrBranchCode = BranchCode;
            }
            string Narrative = "ExtRefNo: " + OrderId + " via " + SendingIdentityID;
            string[] PostStatus = new string[10];
            string ResponseDesc = null;
            string CBSRefNo = null;
            if (DrBankAccountNo == "1092210715371")
                DrCurrency = "USD";
            if (CrBankAccountNo == "1092210715371")
                CrCurrency = "USD";
            //get url
            string url = GetAPIParameters("FCUBS", "Post", "URL");
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            //HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@"http://10.1.200.102:7003/FCUBSRTService/FCUBSRTService?wsdl");
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            //<fcub:USERID>TELEBIRR</fcub:USERID>  Test
            //<fcub:USERID>TELEBIRRBR</fcub:USERID>  Prod
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSRTService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:CREATETRANSACTION_FSFS_REQ>
                     <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>" + SourceName + @"</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>
                        <fcub:MSGID>" + MSGID + @"</fcub:MSGID>
                        <fcub:USERID>ESBUSER</fcub:USERID>
                        <fcub:BRANCH>000</fcub:BRANCH>
                        <fcub:MODULEID>RT</fcub:MODULEID>
                        <fcub:SERVICE>FCUBSRTService</fcub:SERVICE>
                        <fcub:OPERATION>CreateTransaction</fcub:OPERATION>
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Transaction-Details>
                           <fcub:PRD>" + ProdName + @"</fcub:PRD>
                           <fcub:BRN>" + BranchCode + @"</fcub:BRN>
                           <fcub:TXNBRN>" + DrBranchCode + @"</fcub:TXNBRN>
                           <fcub:TXNACC>" + DrBankAccountNo + @"</fcub:TXNACC>
                           <fcub:TXNCCY>" + DrCurrency + @"</fcub:TXNCCY>
                           <fcub:TXNAMT>" + Amount + @"</fcub:TXNAMT>               
                           <fcub:OFFSETBRN>" + OffSetBranchCode + @"</fcub:OFFSETBRN>
                           <fcub:OFFSETACC>" + CrBankAccountNo + @"</fcub:OFFSETACC>
                           <fcub:OFFSETCCY>" + CrCurrency + @"</fcub:OFFSETCCY>     
                           <fcub:NARRATIVE>" + Narrative + @"</fcub:NARRATIVE>               
                        </fcub:Transaction-Details>
                     </fcub:FCUBS_BODY>
                  </fcub:CREATETRANSACTION_FSFS_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");
            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                PostStatus[0] = "1";
                PostStatus[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    PostStatus[1] = ExtractData(0, "<MSGSTAT", ">", "</MSGSTAT>", ServiceResult); //Code
                    ResponseDesc = ExtractData(0, "<EDESC", ">", "</EDESC>", ServiceResult); //Description
                    CBSRefNo = ExtractData(0, "<XREF", ">", "</XREF>", ServiceResult); //Description
                    if (PostStatus[1] == "FAILURE")
                    {
                        PostStatus[0] = "-1";
                        PostStatus[2] = ResponseDesc;
                    }
                    else
                    {
                        PostStatus[0] = "0";
                        PostStatus[1] = "SUCCESS";
                        PostStatus[2] = CBSRefNo;
                    }
                }
            }
        XXX:
            return PostStatus;
        }

        public string[] RevereseCBSTransaction(string ExtRefNo, string SourceName, string ProdName)
        {
            string[] PostStatus = new string[10];
            string ResponseDesc = null;
            //get url
            string url = GetAPIParameters("FCUBS", "Reverse", "URL");
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            //<fcub:USERID>TELEBIRR</fcub:USERID>   //Test
            //<fcub:USERID>TELEBIRRBR</fcub:USERID>   //Prod
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSRTService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:REVERSETRANSACTION_IOPK_REQ>
                      <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>" + SourceName + @"</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>
                        <fcub:USERID>ESBUSER</fcub:USERID>
                        <fcub:BRANCH>000</fcub:BRANCH>
                        <!--Optional:-->
                        <fcub:MODULEID>RT</fcub:MODULEID>
                        <fcub:SERVICE>FCUBSRTService</fcub:SERVICE>
                        <fcub:OPERATION>ReverseTransaction</fcub:OPERATION>
                        <!--Optional:-->
                        <fcub:SOURCE_OPERATION>ReverseTransaction</fcub:SOURCE_OPERATION>
                        <fcub:SOURCE_USERID>ESBUSER</fcub:SOURCE_USERID>
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Transaction-Details-IO>
                           <fcub:XREF>" + ExtRefNo + @"</fcub:XREF>
                           <fcub:FCCREF>" + ExtRefNo + @"</fcub:FCCREF>
                        </fcub:Transaction-Details-IO>
                     </fcub:FCUBS_BODY>
                  </fcub:REVERSETRANSACTION_IOPK_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");
            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                PostStatus[0] = "1";
                PostStatus[1] = "Connection Timeout";
                goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    PostStatus[1] = ExtractData(0, "<MSGSTAT", ">", "</MSGSTAT>", ServiceResult); //Code
                    PostStatus[3] = ExtractData(0, "<MSGID", ">", "</MSGID>", ServiceResult); //ref no
                    if (PostStatus[1] == "FAILURE")
                    {
                        ResponseDesc = ExtractData(0, "<EDESC", ">", "</EDESC>", ServiceResult); //Description
                        PostStatus[0] = "-1";
                        PostStatus[2] = ResponseDesc;

                    }
                    else
                    {
                        ResponseDesc = ExtractData(0, "<WDESC", ">", "</WDESC>", ServiceResult); //Description
                        PostStatus[0] = "0";
                        PostStatus[1] = "SUCCESS";
                        PostStatus[2] = ResponseDesc;
                    }
                }
            }
        XXX:
            return PostStatus;
        }

        public string ExtractData(int initialIndex, string bookMark, string preMark, string postMark, string DataString)
        {
            if (String.IsNullOrEmpty(DataString) || initialIndex < 0)
                return null;
            string requiredData = null;
            int NamestartIndex = DataString.IndexOf(bookMark, initialIndex);
            if (NamestartIndex == -1) return null;
            int StartIndex = DataString.IndexOf(preMark, NamestartIndex) + 1;
            if (StartIndex == -1) return null;
            int EndIndex = DataString.IndexOf(postMark, StartIndex);
            if (EndIndex == -1) return null;
            requiredData = DataString.Substring(StartIndex, EndIndex - StartIndex);
            requiredData = requiredData.Replace('"', ' ').Trim();
            return requiredData;

        }

        public int GetIndex(string Key, string BookMark)
        {
            if (String.IsNullOrEmpty(Key) || String.IsNullOrEmpty(BookMark))
                return 0;
            int NamestartIndex = BookMark.IndexOf(Key, 0);
            return NamestartIndex;

        }
        public string PingStatus(string IP)
        {
            //check current status (ping or not)
            System.Net.NetworkInformation.Ping ping = new System.Net.NetworkInformation.Ping();
            System.Net.NetworkInformation.PingReply reply = ping.Send(IP);
            return reply.Status.ToString();
        }

        public void RegisterCustomer(string CustomerId, string Biller, string FName, string SName, string LName, string MobNo, string PlateNo)
        {
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            Biller biller = db.Billers.Where(s => s.BillerId == Biller).FirstOrDefault();
            int BillerId = biller.BId;
            DateTime TxnDate = DateTime.Now;
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            //Check for repeat registration
            com = new SqlCommand("SELECT * FROM [dbo].[CustomerInfo] WHERE CustomerId = '" + CustomerId + "'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Close();
            }
            else
            {
                reader.Close();
                com = new SqlCommand("INSERT INTO [dbo].[CustomerInfo] ([Biller], [CustomerId], [FirstName], [SecondName], [LastName], [MobileNo], [Grade], [Status], [CreatedDate]) VALUES (" + BillerId + ", '" + CustomerId + "','" + FName + "','" + SName + "','" + LName + "','" + MobNo + "','" + PlateNo + "','Registered','" + TxnDate + "')", con);
                reader = com.ExecuteReader();
                reader.Close();
            }
        }

        public int RecordLog(int LogId, string Col, string Val)
        {
            DateTime TxnDate = DateTime.Now;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            if(Col == "RequestDateTime")
            {
                com = new SqlCommand("INSERT INTO [dbo].[TxnLog] ([Method], [RequestDateTime]) VALUES (" + LogId + ", '" + TxnDate + "')", con);
                reader = com.ExecuteReader();
                reader.Close();
                //get log id
                com = new SqlCommand("SELECT * FROM [dbo].[TxnLog] WHERE Method = " + LogId + " AND RequestDateTime = '" + TxnDate + "'", con);
                reader = com.ExecuteReader(); 
                if (reader.HasRows)
                {
                    reader.Read();
                    LogId = Int32.Parse(reader["LogId"].ToString());
                }
                reader.Close();
            }
            else
            {
                com = new SqlCommand("UPDATE [dbo].[TxnLog] SET " + Col + " = N'" + Val + "' WHERE LogId = " + LogId, con);
                reader = com.ExecuteReader();
                reader.Close();
            }
            return LogId;
        }

        public string GetOffSetAccountNo(string Service)
        {
            string AccNo = null;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            com = new SqlCommand("SELECT * FROM [dbo].[Services] WHERE ServiceCode = '" + Service + "'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                AccNo = reader["OffSetAccNo"].ToString();
            }
            reader.Close();
            return AccNo;
        }

        public string Get_GL(string AccNo)
        {
            string AccName = null;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            com = new SqlCommand("SELECT * FROM [dbo].[GL_List] WHERE AccountNo = '" + AccNo + "'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                AccName = reader["AccountName"].ToString();
            }
            reader.Close();
            return AccName;
        }

        public bool Check_Duplicate_RefNo(string ServiceCode, string RefNo)
        {
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            com = new SqlCommand("SELECT * FROM TxnLog Tx, APIMethods M, [Services] S WHERE Tx.Method = M.MethodId AND M.[Service] = S.ServiceId AND Tx.IncomingRequestRefNo ='" + RefNo + "' AND S.ServiceCode = '" + ServiceCode + "'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Close();
                return true;
            }
            return false;
        }

        public string GetBranchName(string BranchCode)
        {
            string BranchName = null;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            com = new SqlCommand("SELECT * FROM [dbo].[Branch] WHERE BranchCode = '" + BranchCode + "'", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                BranchName = reader["BranchName"].ToString();
            }
            reader.Close();
            return BranchName;
        }


        public string GetAPIParameters(string Service, string Method, string Para)
        {
            string value = null;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            if (Para == "SourceName" || Para == "ProductName" || Para == "URL" || Para == "UserName" || Para == "Password" || Para == "MethodId")
            {
                com = new SqlCommand("SELECT * FROM [dbo].[APIMethods] A, [dbo].[Services] S WHERE A.Service = S.ServiceId AND A.MethodName = '" + Method + "' AND S.ServiceCode = '" + Service + "'", con);
                reader = com.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    if (Para == "SourceName") value = reader["MethodCode"].ToString();
                    else if (Para == "ProductName") value = reader["MethodType"].ToString();
                    else if (Para == "URL") value = reader["URL"].ToString();
                    else if (Para == "UserName") value = reader["Key"].ToString();
                    else if (Para == "Password") value = reader["Password"].ToString();
                    else if (Para == "MethodId") value = reader["MethodId"].ToString();
                }
                reader.Close();
            }
            else if (Para == "ServiceType" || Para == "Description" || Para == "OffSetAccNo" || Para == "ServiceCode" || Para == "UserName" || Para == "Password" || Para == "ServiceId")
            {
                com = new SqlCommand("SELECT * FROM [dbo].[Services] WHERE ServiceCode = '" + Service + "'" , con);
                reader = com.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    if (Para == "OffSetAccNo") value = reader["OffSetAccNo"].ToString();
                    else if (Para == "ServiceType") value = reader["ServiceType"].ToString();
                    else if (Para == "ThirdParty") value = reader["ThirdParty"].ToString();
                    else if (Para == "ServiceId") value = reader["ServiceId"].ToString();
                    else if (Para == "Description") value = reader["Description"].ToString();
                }
                reader.Close();
            }
            return value;
        }

        public string SendSMS(string MobileNo, string Message)
        {
            string Status = "Failed", json = null;
            //Assign API KEY which received from OPENWEATHERMAP.ORG  
            string username = "playsms";
            string password = "playsms";
            string ShortCode = "8027";
            //API path with CITY parameter and other parameters.  
            string url = string.Format("http://10.10.13.82:13131/cgi-bin/sendsms?username={0}&password={1}&from={2}&to={3}&text={4}&priority=2", username, password, ShortCode, MobileNo, Message);
            using (WebClient client = new WebClient())
            {
                json = client.DownloadString(url);
                Status = ExtractData(0, "{", ":", "}", json);
                if (Status == "0")
                    Status = "SUCCESS";
                else
                    Status = "FAILURE";
            }
            return Status;
        }

        public Bill_Data Dearsh_Fetch_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            int LogId = 0;
            string json = null;
            Bill_Data billdata = new Bill_Data();
            using (WebClient client = new WebClient())
            {
                //if (Bill == "240000000")
                //{
                //    billdata.manifest_id = "AbzISNDIsInR5cCG2";
                //    billdata.customer_id = "12345678";
                //    billdata.name = "ABC International Plc";
                //    billdata.bill_id = Bill;
                //    billdata.bill_desc = "'December Bill':'123.00','Penality':'500.50'";
                //    billdata.reason = "PERIOD_November_2022";
                //    billdata.partial_pay_allowed = false;
                //    billdata.amount_due = (decimal)50.50;
                //    billdata.due_dt = "2023-12-31";
                //    return billdata;
                //}

                //if (Bill == "230000000")
                //{
                //    billdata.manifest_id = "PEzI1biAsInR5cCR9";
                //    billdata.customer_id = "12345678";
                //    billdata.name = "ኤፍሬም ጥላሁን";
                //    billdata.bill_id = Bill;
                //    billdata.bill_desc = "'Nvember Bill':'120.00','Penality':'30.50'";
                //    billdata.reason = "PERIOD_November_2022";
                //    billdata.partial_pay_allowed = false;
                //    billdata.amount_due = (decimal)320.50;
                //    billdata.due_dt = "2023-12-31";
                //    return billdata;
                //}

                client.Headers.Add("api-key", api_key);
                client.Headers.Add("api-secret", api_secret);
                //call the web service from Derash
                json = client.DownloadString(url);
                billdata = (new JavaScriptSerializer()).Deserialize<Bill_Data>(json);
                LogId = RecordLog(LogId, "ResponseStatus", "OK");
                LogId = RecordLog(LogId, "ResponseEntity", billdata.name);
                LogId = RecordLog(LogId, "Responsevalue", billdata.amount_due.ToString());
                LogId = RecordLog(LogId, "ResponseRefNo", billdata.manifest_id);
            }
            return billdata;
        }
        public ResponseMsg Dearsh_Payment_API(string RefNo, string amount,string paid_dt, string payee_mobile,string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            ResponseMsg Msg = new ResponseMsg();
            string json = null;
            var client = new RestSharp.RestClient(url);
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "application/json");
            request.AddHeader("api-key", api_key);
            request.AddHeader("api-secret", api_secret);
            var body = @"{
                        " + "\n" +
                                    @"    ""manifest_id"": """ + RefNo + @""",
                        " + "\n" +
                                    @"    ""bill_id"": """ + Bill + @""",
                        " + "\n" +
                                    @"    ""amount"": """ + amount + @""",
                        " + "\n" +
                                    @"    ""paid_dt"": """ + paid_dt + @""",
                        " + "\n" +
                                    @"    ""payee_mobile"": """ + payee_mobile + @""",
                        " + "\n" +
                                    @"    ""paid_at"": """ + paid_at + @""",
                        " + "\n" +
                                    @"    ""txn_code"": """ + RefNo + @"""
                        " + "\n" +

                    @"}";
            request.AddParameter("application/json", body, ParameterType.RequestBody);
            IRestResponse response = client.Execute(request);
            json = response.Content;
            Msg.StatusCode = Int32.Parse(ExtractData(0, "statusCode", ":", ",", json));
            Msg.message = ExtractData(0, "message", ":", "}", json) + ".";
            Msg.ErrorMsg = ExtractData(0, "error", ":", "}", json) + ".";
            return Msg;
        }
        public Bill_Data GuzoGo_Fetch_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            int LogId = 0;
            string json = null;
            Bill_Data billdata = new Bill_Data();
            var client = new RestSharp.RestClient(url);
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "application/json");
            var body = @"{
                        " + "\n" +
                                    @"    ""pnr"": """ + Bill + @""",
                        " + "\n" +
                                    @"    ""token"": """ + api_key + @"""
                        " + "\n" +
            @"}";
            request.AddParameter("application/json", body, ParameterType.RequestBody);
            IRestResponse response = client.Execute(request);
            json = response.Content;
            if (ExtractData(0, "pnr", ":", ",", json) == null)
            {
                billdata.bill_desc = "statusCode: (" + ExtractData(0, "status", ":", ",", json) + ")";
                billdata.bill_desc = billdata.bill_desc + " " + ExtractData(0, "msg", ":", "!", json) + ".";
                LogId = RecordLog(LogId, "ResponseStatus", "Failed");
                return billdata;
            }
            billdata.manifest_id = "NonDRS_" + Biller;
            billdata.customer_id = ExtractData(0, "phoneNumber", ":", ",", json);
            billdata.name = ExtractData(0, "firstName", ":", ",", json) + " " + ExtractData(0, "lastName", ":", ",", json);
            billdata.bill_id = Bill;
            billdata.bill_desc = ExtractData(0, "uapi_passenger_ref", ":", ",", json);
            billdata.reason = ExtractData(0, "passportNumber", ":", ",", json);
            billdata.partial_pay_allowed = false;
            billdata.amount_due = decimal.Parse(ExtractData(0, "totalPrice", "B", ",", json));
            billdata.due_dt = ExtractData(0, "createdAt", ":", ",", json);
            return billdata;
        }

        public ResponseMsg GuzoGo_Payment_API(string RefNo, string amount, string paid_dt, string payee_mobile, string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            ResponseMsg Msg = new ResponseMsg();
            string json = null;
            string PayStat = "paid";
            string branch = paid_at;
            string DepName = "From Account";
            string DepPhone = payee_mobile;
            //string tin = "abcd1300000";
            //string Company = "ABC";
            string CbsRef = RefNo;
            string channel = "Digital Banking";
            var client = new RestSharp.RestClient(url);
            client.Timeout = -1;
            var request = new RestRequest(Method.POST);
            request.AddHeader("Content-Type", "application/json");
            var body = @"{
                        " + "\n" +
                                    @"    ""pnr"": """ + Bill + @""",
                        " + "\n" +
                                    @"    ""token"": """ + api_key + @""",
                        " + "\n" +
                                    @"    ""payment_status"": """ + PayStat + @""",
                        " + "\n" +
                                    @"    ""branch_name"": """ + branch + @""",
                        " + "\n" +
                                    @"    ""depositor_name"": """ + DepName + @""",
                        " + "\n" +
                                    @"    ""depositor_phone"": """ + DepPhone + @""",
                        " + "\n" +
//                                    @"    ""tin_number"": """ + tin + @""",
//                        " + "\n" +
//                                    @"    ""company_name"": """ + Company + @""",
//                        " + "\n" +
                                    @"    ""CBSTransId"": """ + CbsRef + @""",
                        " + "\n" +
                                    @"    ""payment_channel"": """ + channel + @"""
                        " + "\n" +

                    @"}";
            request.AddParameter("application/json", body, ParameterType.RequestBody);
            IRestResponse response = client.Execute(request);
            json = response.Content;
            Msg.StatusCode = Int32.Parse(ExtractData(0, "status", ":", ",", json));
            Msg.message = ExtractData(0, "msg", ":", "}", json) + ".";
            Msg.ErrorMsg = ExtractData(0, "msg", ":", "}", json) + ".";
            return Msg;
        }

        public Bill_Data TeleBirr_Fetch_API(string Biller, string MobileNo, string api_key, string api_secret, string url)
        {
            Bill_Data billdata = new Bill_Data();
            string OwnRefNo = DateTime.Now.ToString("yyyymmhhMMsstt");
            string Txndate = DateTime.Now.ToString("yymmhhMMss");
            billdata.manifest_id = "NonDRS_" + Biller;
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            // <req:ThirdPartyID>Cust_query</req:ThirdPartyID> Test: Query
            // <req:Identifier>0017</req:Identifier> Test: queryoperator
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:api=""http://cps.huawei.com/synccpsinterface/api_requestmgr"" xmlns:req=""http://cps.huawei.com/synccpsinterface/request"" xmlns:com=""http://cps.huawei.com/synccpsinterface/common""> 
               <soapenv:Header/> 
               <soapenv:Body> 
                  <api:Request> 
                     <req:Header> 
                        <req:Version>1.0</req:Version> 
                        <req:CommandID>QueryCustomerBriefInfo</req:CommandID> 
                        <req:OriginatorConversationID>20230905152500</req:OriginatorConversationID> 
                        <req:Caller>
                           <req:CallerType>2</req:CallerType>
                           <req:ThirdPartyID>Cust_query</req:ThirdPartyID>
                           <req:Password>" + api_key + @"</req:Password>
                        </req:Caller>
                        <req:KeyOwner>1</req:KeyOwner> 
                        <req:Timestamp>" + OwnRefNo + @"</req:Timestamp> 
                     </req:Header> 
                     <req:Body> 
                        <req:Identity> 
                           <req:Initiator> 
                              <req:IdentifierType>14</req:IdentifierType> 
                              <req:Identifier>0017</req:Identifier> 
                              <req:SecurityCredential>" + api_secret + @"</req:SecurityCredential> 
                           </req:Initiator> 
                           <req:ReceiverParty> 
                              <req:IdentifierType>1</req:IdentifierType> 
                              <req:Identifier>" + MobileNo + @"</req:Identifier> 
                           </req:ReceiverParty> 
                        </req:Identity> 
                        <req:QueryCustomerBriefInfoRequest/> 
                        <req:Remark>From Bank to MM</req:Remark> 
                     </req:Body> 
                  </api:Request> 
               </soapenv:Body> 
            </soapenv:Envelope>");

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string FName = null; string SName = null; string LName = null; int index = 0; string Status = null; string RefNo = null;
                    string ServiceResult = rd.ReadToEnd();
                    Status = ExtractData(0, "<res:ResultCode", ">", "</res:ResultCode>", ServiceResult);
                    if (Status == "0")
                    {
                        index = GetIndex("[KYC][Personal Details][First Name]", ServiceResult);
                        FName = ExtractData(index, "<com:KYCValue", ">", "</com:KYCValue>", ServiceResult);
                        index = GetIndex("[KYC][Personal Details][Middle Name]", ServiceResult);
                        SName = ExtractData(index, "<com:KYCValue", ">", "</com:KYCValue>", ServiceResult);
                        index = GetIndex("[KYC][Personal Details][Last Name]", ServiceResult);
                        LName = ExtractData(index, "<com:KYCValue", ">", "</com:KYCValue>", ServiceResult);
                        billdata.name = FName + " " + SName + " " + LName;
                        
                        billdata.bill_id = MobileNo;
                        billdata.amount_due = (decimal)0.0;
                        billdata.due_dt = DateTime.Today.ToString("yyyy-MM-dd");
                    }
                    else
                    {
                        billdata.name = null;
                    }
                }
            }
            return billdata;
        }

        public Bill_Data TeleBirr_Fetch_Merchant_API(string Biller, string MobileNo, string api_key, string api_secret, string url)
        {
            Bill_Data billdata = new Bill_Data();
            string OwnRefNo = DateTime.Now.ToString("yyyymmhhMMsstt");
            string Txndate = DateTime.Now.ToString("yymmhhMMss");
            billdata.manifest_id = "NonDRS_" + Biller;
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            // <req:ThirdPartyID>Cust_query</req:ThirdPartyID> Test: Query
            // <req:Identifier>0017</req:Identifier> Test: queryoperator
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:api=""http://cps.huawei.com/synccpsinterface/api_requestmgr"" xmlns:req=""http://cps.huawei.com/synccpsinterface/request"" xmlns:com=""http://cps.huawei.com/synccpsinterface/common"">
               <soapenv:Header/>
               <soapenv:Body>
                  <api:Request>
                     <req:Header>
                        <req:Version>1.0</req:Version>
                        <req:CommandID>QueryOrganizationInfo</req:CommandID>
                       <req:Caller>
                           <req:CallerType>2</req:CallerType>
                           <req:ThirdPartyID>Cust_query</req:ThirdPartyID>
                           <req:Password>" + api_key + @"</req:Password>
                        </req:Caller>
                        <req:KeyOwner>1</req:KeyOwner>
                        <req:Timestamp>" + OwnRefNo + @"</req:Timestamp>
                     </req:Header>
                     <req:Body>
                        <req:Identity>
                           <req:Initiator>
                              <req:IdentifierType>14</req:IdentifierType>
                              <req:Identifier>0017</req:Identifier>
                              <req:SecurityCredential>" + api_secret + @"</req:SecurityCredential>
                           </req:Initiator>
                           <req:ReceiverParty>
                              <req:IdentifierType>4</req:IdentifierType>
                              <req:Identifier>" + MobileNo + @"</req:Identifier>
                           </req:ReceiverParty>
                        </req:Identity>
                        <req:QueryOrganizationInfoRequest/>
                        <req:Remark>test</req:Remark>
                     </req:Body>
                  </api:Request>
               </soapenv:Body>
            </soapenv:Envelope>");

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string FName = null; string SName = null;  int index = 0; string Status = null; 
                    string ServiceResult = rd.ReadToEnd();
                    Status = ExtractData(0, "<res:ResultCode", ">", "</res:ResultCode>", ServiceResult);
                    if (Status == "0")
                    {
                        index = GetIndex("OrganizationBasicData", ServiceResult);
                        FName = ExtractData(index, "<res:OrganizationName", ">", "</res:OrganizationName>", ServiceResult);
                        index = GetIndex("[Organization Details][Organization Type]", ServiceResult);
                        SName = ExtractData(index, "<res:SegmentName", ">", "</res:SegmentName>", ServiceResult);
                        billdata.name = FName + " (" + SName + ")";
                        billdata.bill_id = MobileNo;
                        billdata.amount_due = (decimal)0.0;
                        billdata.due_dt = DateTime.Today.ToString("yyyy-MM-dd");
                    }
                    else
                    {
                        billdata.name = null;
                    }
                }
            }
            return billdata;
        }
        public ResponseMsg TeleBirr_Payment_API(string RefNo, string amount, string paid_dt, string payee_mobile, string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            ResponseMsg Msg = new ResponseMsg();
            Bill_Data billdata = new Bill_Data();
            string MobileNo = "";
            string OwnRefNo = DateTime.Now.ToString("yyyymmhhMMsstt");
            string Txndate = DateTime.Now.ToString("yymmhhMMss");
            MobileNo = "251" + Bill.Substring(1);
            billdata.customer_id = MobileNo;

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:api=""http://cps.huawei.com/synccpsinterface/api_requestmgr"" xmlns:req=""http://cps.huawei.com/synccpsinterface/request"" xmlns:com=""http://cps.huawei.com/synccpsinterface/common"">
               <soapenv:Header/>
               <soapenv:Body>
                   <api:Request>
                     <req:Header>
                        <req:Version>1.0</req:Version>
                        <req:CommandID>InitTrans_DepositfromBankOrg</req:CommandID>
                        <req:OriginatorConversationID>" + RefNo + @"</req:OriginatorConversationID>
                        <req:Caller>
                           <req:CallerType>2</req:CallerType>
                           <req:ThirdPartyID>Debub_Bank</req:ThirdPartyID>
                           <req:Password>" + api_key + @"</req:Password>
                        </req:Caller>
                        <req:KeyOwner>1</req:KeyOwner>
                        <req:Timestamp>" + OwnRefNo + @"</req:Timestamp>
                     </req:Header>
                     <req:Body>
                        <req:Identity>
                           <req:Initiator>
                              <req:IdentifierType>12</req:IdentifierType>
                              <req:Identifier>001701</req:Identifier>
                              <req:SecurityCredential>" + api_secret + @"</req:SecurityCredential>
                              <req:ShortCode>0017</req:ShortCode>
                           </req:Initiator>
                           <req:ReceiverParty>
                              <req:IdentifierType>1</req:IdentifierType>
                              <req:Identifier>" + MobileNo + @"</req:Identifier>
                           </req:ReceiverParty>
                        </req:Identity>
                        <req:TransactionRequest>
                           <req:Parameters>
                              <req:Amount>" + amount + @"</req:Amount>
                              <req:Currency>ETB</req:Currency>
                           </req:Parameters>
                        </req:TransactionRequest>
                        <req:Remark>" + RefNo + @"</req:Remark>
                     </req:Body>
                  </api:Request>
               </soapenv:Body>
            </soapenv:Envelope>");

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }
            string Status = null;
            string ExtRefNo = null;
            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    Status = ExtractData(0, "<res:ResultCode", ">", "</res:ResultCode>", ServiceResult);
                    ExtRefNo = ExtractData(0, "<res:TransactionID", ">", "</res:TransactionID>", ServiceResult);
                    Msg.StatusCode = Int32.Parse(Status);
                    if (Status == "0")
                    {
                        Msg.StatusCode = 200;
                        Msg.message = ExtRefNo;
                        Msg.Status = "SUCCESS";
                        Msg.ErrorMsg = "None";
                        //string x = SendSMS("0911434693", FundAmount.ToString("00.00") + " Birr transfered to " + AccNoTo + " (" + BankName + ") successfully.");
                    }
                    else
                    {
                        Msg.Status = "FAILURE";
                        Msg.message = "Failure";
                        Msg.ErrorMsg = "Failed - " + ExtractData(0, "res:ResultDesc", ">", "</at:res:ResultDesc>", ServiceResult);
                    }
                }
            }
            return Msg;
        }

        public ResponseMsg TeleBirr_Payment_Merchant__API(string RefNo, string amount, string paid_dt, string payee_mobile, string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            ResponseMsg Msg = new ResponseMsg();
            Bill_Data billdata = new Bill_Data();
            string MobileNo = "";
            string OwnRefNo = DateTime.Now.ToString("yyyymmhhMMsstt");
            string Txndate = DateTime.Now.ToString("yymmhhMMss");
            MobileNo = Bill;
            billdata.customer_id = MobileNo;

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            XmlDocument SOAPReqBody = new XmlDocument();
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:api=""http://cps.huawei.com/synccpsinterface/api_requestmgr"" xmlns:req=""http://cps.huawei.com/synccpsinterface/request"" xmlns:com=""http://cps.huawei.com/synccpsinterface/common"">
               <soapenv:Header/>
               <soapenv:Body>
                         <api:Request>
                     <req:Header>
                        <req:Version>1.0</req:Version>
                        <req:CommandID>InitTrans_DepositfromBankOrg</req:CommandID>
                        <req:OriginatorConversationID>" + RefNo + @"</req:OriginatorConversationID>
                        <req:Caller>
                           <req:CallerType>2</req:CallerType>
                           <req:ThirdPartyID>Debub_Bank</req:ThirdPartyID>
                           <req:Password>" + api_key + @"</req:Password>
                        </req:Caller>
                        <req:KeyOwner>1</req:KeyOwner>
                        <req:Timestamp>" + OwnRefNo + @"</req:Timestamp>
                     </req:Header>
                     <req:Body>
                        <req:Identity>
                           <req:Initiator>
                              <req:IdentifierType>12</req:IdentifierType>
                              <req:Identifier>001701</req:Identifier>
                              <req:SecurityCredential>" + api_secret + @"</req:SecurityCredential>
                              <req:ShortCode>0017</req:ShortCode>
                           </req:Initiator>
                           <req:ReceiverParty>
                              <req:IdentifierType>4</req:IdentifierType>
                              <req:Identifier>" + MobileNo + @"</req:Identifier>
                           </req:ReceiverParty>
                        </req:Identity>
                        <req:TransactionRequest>
                           <req:Parameters>
                              <req:Amount>" + amount + @"</req:Amount>
                              <req:Currency>ETB</req:Currency>
                           </req:Parameters>
                        </req:TransactionRequest>
                        <req:Remark>" + RefNo + @"</req:Remark>
                     </req:Body>
                  </api:Request>
               </soapenv:Body>
            </soapenv:Envelope>");                                                                  


            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }
            string Status = null;
            string ExtRefNo = null;
            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    Status = ExtractData(0, "<res:ResultCode", ">", "</res:ResultCode>", ServiceResult);
                    ExtRefNo = ExtractData(0, "<res:TransactionID", ">", "</res:TransactionID>", ServiceResult);
                    Msg.StatusCode = Int32.Parse(Status);
                    if (Status == "0")
                    {
                        Msg.StatusCode = 200;
                        Msg.message = ExtRefNo;
                        Msg.Status = "SUCCESS";
                        Msg.ErrorMsg = "None";
                        //string x = SendSMS("0911434693", FundAmount.ToString("00.00") + " Birr transfered to " + AccNoTo + " (" + BankName + ") successfully.");
                    }
                    else
                    {
                        Msg.Status = "FAILURE";
                        Msg.message = "Failure";
                        Msg.ErrorMsg = "Failed - " + ExtractData(0, "res:ResultDesc", ">", "</at:res:ResultDesc>", ServiceResult);
                    }
                }
            }
            return Msg;
        }

        public Bill_Data Nedaj_Fetch_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            int LogId = 0;
            string json = null;
            Bill_Data billdata = new Bill_Data();

            var client = new WebClient { Credentials = new NetworkCredential("debubglobalbankadmin@valanides.com", "UiIjuXJ+x+XSDy{") };
            string credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(api_key + ":" + api_secret));
            client.Headers[HttpRequestHeader.Authorization] = "Basic " + credentials;
            client.Headers[HttpRequestHeader.ContentType] = "application/json";
            string Fullurl = string.Format(url + "/{0}", Bill);
            var response = client.DownloadString(Fullurl);
            json = response.ToString();

            string FName = ExtractData(0, "firstName", ":", ",", json);
            string SName = ExtractData(0, "middleName", ":", ",", json) ;
            string LName = ExtractData(0, "lastName", ":", ",", json);
            string MobNo = ExtractData(0, "phoneNumber", ":", ",", json);
            string PlateNo = ExtractData(0, "carRegionCode", ":", "}", json) + "-" + ExtractData(0, "carCode", ":", ",", json) + "-" + ExtractData(0, "plateNumber", ":", ",", json);
            billdata.manifest_id = "NonDRS_" + Biller;
            billdata.customer_id = MobNo;
            billdata.name = (FName + " " + SName + " " + LName).Trim();
            billdata.bill_id = Bill;
            billdata.bill_desc = PlateNo;
            billdata.reason = "Nedaj Registration";
            billdata.partial_pay_allowed = false;
            billdata.amount_due = (decimal)1.00;
            billdata.due_dt = DateTime.Today.ToString("yyyy-MM-dd");
            RegisterCustomer(Bill, Biller, FName, SName, LName, MobNo, PlateNo);
            return billdata;
        }

        public ResponseMsg Nedaj_Link_API(string RefNo, string amount, string paid_dt, string payee_mobile, string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            string[] PostStatus = new string[10];
            ResponseMsg Msg = new ResponseMsg();
            string json = null;
            //get the account number and chcek 
            string AccountNo = null;
            PostStatus = FetcAccountNoFromCBS(RefNo, "Debit");
            if (PostStatus[0] != "0")
            {
                Msg.StatusCode = 100;
                Msg.Status = "FAILURE";
                Msg.message = "FAILURE";
                Msg.ErrorMsg = "Failed";
                goto XXX;
            }
            else
                AccountNo = PostStatus[2];
            try
            {
                var client = new WebClient { Credentials = new NetworkCredential("debubglobalbankadmin@valanides.com", "UiIjuXJ+x+XSDy{") };
                string credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(api_key + ":" + api_secret));
                client.Headers[HttpRequestHeader.Authorization] = "Basic " + credentials;
                client.Headers[HttpRequestHeader.ContentType] = "application/json";
                string Fullurl = string.Format(url + "/{0}", Bill);
                var body = @"{
                        " + "\n" +
                                        @"    ""account_number"": """ + AccountNo + @"""
                        " + "\n" +

                        @"}";
                var response = client.UploadString(Fullurl, "PUT", body);
                json = response.ToString();
                string AccNo = ExtractData(0, "accountNumber", ":", ",", json);
                if (!String.IsNullOrEmpty(AccNo))
                {
                    Msg.StatusCode = 200;
                    Msg.message = "Account Linked to Id successfuly.";
                    Msg.Status = "SUCCESSFUL";
                    Msg.ErrorMsg = "None";
                }
                else
                {
                    Msg.StatusCode = 100;
                    Msg.Status = "FAILURE";
                    Msg.message = "Failure";
                    Msg.ErrorMsg = "Failed";
                }
            }
            catch (WebException ex)
            {
                Msg.StatusCode = 404;
                Msg.Status = "FAILURE";
                Msg.ErrorMsg = "Transaction Failed";
                Msg.message = "Id is Not Found.";
            } 
            XXX:
            return Msg;
        }

        public Bill_Data Kacha_Fetch_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            int LogId = 0;
            string json = null;
            Bill_Data billdata = new Bill_Data();
            //get the account number and chcek 
                var client = new WebClient { Credentials = new NetworkCredential("debubglobalbankadmin@valanides.com", "UiIjuXJ+x+XSDy{") };
                string credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(api_key + ":" + api_secret));
                client.Headers[HttpRequestHeader.Authorization] = "Basic " + credentials;
                client.Headers[HttpRequestHeader.ContentType] = "application/json";
                string Fullurl = string.Format(url);
                var body = @"{
                        " + "\n" +
                                        @"    ""account"": """ + Bill + @"""
                        " + "\n" +

                        @"}";
                var response = client.UploadString(Fullurl, "POST", body);
                json = response.ToString();
                //string StatusCode = ExtractData(0, "status_code", ":", ",", json);

                string FullName = ExtractData(0, "name", ":", ",", json);
                billdata.manifest_id = "NonDRS_" + Biller;
                billdata.customer_id = Bill;
                billdata.name = FullName;
                billdata.bill_id = Bill;
                billdata.bill_desc = ExtractData(0, "detail", ":", "}", json);
                billdata.reason = ExtractData(0, "limit", ":", ",", json); 
                billdata.partial_pay_allowed = false;
                billdata.amount_due = (decimal)0.00;
                billdata.due_dt = DateTime.Today.ToString("yyyy-MM-dd");
                return billdata;

        }

        public ResponseMsg Kacha_Transfer_API(string RefNo, string amount, string paid_dt, string payee_mobile, string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            string currency = "ETB";
            string reason = "Transfer";
            string[] PostStatus = new string[10];
            ResponseMsg Msg = new ResponseMsg();
            string json = null;
            try
            {
                var client = new WebClient { Credentials = new NetworkCredential("debubglobalbankadmin@valanides.com", "UiIjuXJ+x+XSDy{") };
                string credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(api_key + ":" + api_secret));
                client.Headers[HttpRequestHeader.Authorization] = "Basic " + credentials;
                client.Headers[HttpRequestHeader.ContentType] = "application/json";
                string Fullurl = string.Format(url);
                var body = @"{
                        " + "\n" +
                                    @"    ""account"": """ + Bill + @""",
                        " + "\n" +
                                    @"    ""amount"": """ + amount + @""",
                        " + "\n" +
                                    @"    ""currency"": """ + currency + @""",
                        " + "\n" +
                                    @"    ""trace_number"": """ + RefNo + @""",
                        " + "\n" +
                                    @"    ""reason"": """ + reason + @"""
                        " + "\n" +

                        @"}";
                var response = client.UploadString(Fullurl, "POST", body);
                json = response.ToString();
                string status_code = ExtractData(0, "status_code", ":", ",", json);
                string confirmation_code = ExtractData(0, "reference", ":", ",", json);
                if (status_code == "200")
                {
                    Msg.StatusCode = 200;
                    Msg.message = confirmation_code; 
                    Msg.Status = "SUCCESS";
                    Msg.ErrorMsg = "Fund Transfer successfuly.";
                }
                else
                {
                    Msg.StatusCode = 100;
                    Msg.Status = "FAILURE";
                    Msg.message = "Failure";
                    Msg.ErrorMsg = ExtractData(0, "message", ":", ",", json); 
                }
            }
            catch (WebException ex)
            {
                Msg.StatusCode = 404;
                Msg.Status = "FAILURE";
                Msg.ErrorMsg = "Transaction Failed";
                Msg.message = "Remote Server is not Responding.";
            }
        XXX:
            return Msg;
        }

        public Bill_Data EWallet_Fetch_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            int LogId = 0;
            string json = null;
            url = "https://uat-adapter.walletbir.com/getUserAccount";
            Bill_Data billdata = new Bill_Data();
            //get the account number and chcek 
            var client = new WebClient { Credentials = new NetworkCredential("785412369", "aD2#xRoA") };
            //string credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(api_key + ":" + api_secret));
            client.Headers[HttpRequestHeader.Authorization] = "Basic " + "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiI3ODU0MTIzNjkiLCJsYXRpdHVkZSI6bnVsbCwiYXV0aG9yaXRpZXMiOlsiUk9MRV9VU0VSIl0sImNsaWVudF9pZCI6IkJHVF9CQU5LX0NIQU5ORUwiLCJsb2dnaW5nQXMiOm51bGwsImF1ZCI6WyJBZGFwdGVyX09hdXRoX1Jlc291cmNlX1NlcnZlciJdLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJkZXZpY2VVbmlxdWVJZCI6bnVsbCwic2NvcGUiOlsiUk9MRV9DTElFTlQiXSwiZXhwIjoxNzAxOTM5NjIyLCJyb2xlRXh0ZXJuYWxJZCI6bnVsbCwianRpIjoiZWQxMmE4N2UtN2M2Ny00NjZhLTk5ODYtNmNiYzVlNDE3YjllIiwibG9uZ2l0dWRlIjpudWxsfQ.1yoWYXPLFCawlH3RDezznGqCJjA3qnjLc8hq-REuZ-Q";
            client.Headers[HttpRequestHeader.ContentType] = "application/json";
            string Fullurl = string.Format(url);
            var body = @"{ 
                " + "\n" +
                      @"    ""data"": { 
                " + "\n" +
                      @"        ""userAccountData"": { 
                " + "\n" +
                      @"            ""userAccountIdentifier"": ""940423488""
                " + "\n" +
                      @"        },
                " + "\n" +
                      @"       ""bankTransactionId"": ""3727eagsfafa""
                " + "\n" +
                      @"   }
                " + "\n" +
                      @"}";
            var response = client.UploadString(Fullurl, "POST", body);
            json = response.ToString();
            //string StatusCode = ExtractData(0, "status_code", ":", ",", json);

            string FullName = ExtractData(0, "name", ":", ",", json);
            billdata.manifest_id = "NonDRS_" + Biller;
            billdata.customer_id = Bill;
            billdata.name = FullName;
            billdata.bill_id = Bill;
            billdata.bill_desc = ExtractData(0, "detail", ":", "}", json);
            billdata.reason = ExtractData(0, "limit", ":", ",", json);
            billdata.partial_pay_allowed = false;
            billdata.amount_due = (decimal)0.00;
            billdata.due_dt = DateTime.Today.ToString("yyyy-MM-dd");
            return billdata;
        }
        public Bill_Data SchoolFee_Fetch_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            Bill_Data billdata = new Bill_Data();
            billdata.manifest_id = "NonDRS_" + Biller;
            billdata.customer_id = Bill;
            billdata.bill_id = Bill;
            billdata.bill_desc = "School Fee";
            billdata.reason = "School Fee";
            billdata.partial_pay_allowed = false;
            billdata.due_dt = DateTime.Today.ToString("yyyy-MM-dd");
            string [,] BillList = new string[100,5];
            int i = 0;
            TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
            SqlCommand com = null;
            SqlDataReader reader = null;
            SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
            con.Open();
            //First Find Penality information if any
            com = new SqlCommand("SELECT B.BillId, B.Amount,BTH.PenalityType, BTH.PenalityValue, DATEDIFF(DAY, CONVERT(DATE,DueDate), GETDATE()) AS NoDayDue FROM [dbo].[BillData] B, [dbo].[Batch] BTH, [dbo].[CustomerInfo] C  WHERE B.Batch = BTH.BatchId AND B.Customer = C.CustId AND C.CustomerId = '" + Bill + "' AND B.PayStatus = 'Unpaid' AND CONVERT(DATE,BTH.DueDate) < GETDATE()", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                while(reader.Read())
                {
                    BillList[i, 0] = reader["BillId"].ToString();
                    BillList[i, 1] = reader["Amount"].ToString();
                    BillList[i, 2] = reader["PenalityType"].ToString();
                    BillList[i, 3] = reader["PenalityValue"].ToString();
                    BillList[i, 4] = reader["NoDayDue"].ToString();
                    i++;
                }
            }
            reader.Close();
            //Calculate and save Penality
            for (int j = 0; j < i; j++)
            {
                if (BillList[j, 2] == "Fixed")
                    com = new SqlCommand("UPDATE [dbo].[BillData] SET Penality = " + BillList[j, 3] + " WHERE BillId = " + BillList[j, 0], con);
                else if (BillList[j, 2] == "Rate")
                    com = new SqlCommand("UPDATE [dbo].[BillData] SET Penality = " + decimal.Parse(BillList[j, 3]) * decimal.Parse(BillList[j, 4]) + " WHERE BillId = " + BillList[j, 0], con);
                else if (BillList[j, 2] == "Percentage")
                    com = new SqlCommand("UPDATE [dbo].[BillData] SET Penality = " + decimal.Parse(BillList[j, 1]) * (decimal.Parse(BillList[j, 3]) / 100) * decimal.Parse(BillList[j, 4]) + " WHERE BillId = " + BillList[j, 0], con);
                reader = com.ExecuteReader();
                reader.Close();
            }
            //get bill information
            com = new SqlCommand("SELECT B.Customer, C.FirstName + SPACE(2) + C.SecondName + SPACE(2) + C.LastName AS CustomerName, SUM (B.Amount + B.Penality) AS TotalFee, MIN(BTH.DueDate) AS DueDate FROM [dbo].[BillData] B, [CustomerInfo] C,[Batch] BTH  WHERE B.Customer = C.CustId AND B.Batch = BTH.BatchId AND C.CustomerId = '" + Bill + "' AND B.PayStatus = 'Unpaid' GROUP BY B.Customer, C.FirstName, C.SecondName, C.LastName", con);
            reader = com.ExecuteReader();
            if (reader.HasRows)
            {
                reader.Read();
                billdata.name = reader["CustomerName"].ToString();
                billdata.amount_due = decimal.Parse(reader["TotalFee"].ToString());
                billdata.due_dt = DateTime.Parse(reader["DueDate"].ToString()).ToString("yyyy-MM-dd");
            }
            else
            {
                billdata.name = null;
                billdata.amount_due = decimal.Parse("0.00");
            }
            reader.Close();
            return billdata;
        }

        public ResponseMsg SchoolFee_Payment_API(string RefNo, string amount, string paid_dt, string payee_mobile, string paid_at, string Biller, string Bill, string api_key, string api_secret, string url)
        {
            decimal PayAmount = (decimal)0;
            string[] PostStatus = new string[10];
            ResponseMsg Msg = new ResponseMsg();
            try
            {
                TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
                SqlCommand com = null;
                SqlDataReader reader = null;
                SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
                con.Open();
                com = new SqlCommand("SELECT B.Customer, C.FirstName + SPACE(2) + C.SecondName + SPACE(2) + C.LastName AS CustomerName, SUM (B.PaidAMount + B.Penality) AS TotalFee FROM [dbo].[BillData] B, [CustomerInfo] C WHERE B.Customer = C.CustId AND C.CustomerId = '" + Bill + "' AND B.PayStatus = 'Unpaid' GROUP BY B.Customer, C.FirstName, C.SecondName, C.LastName", con);
                reader = com.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    PayAmount = decimal.Parse(reader["TotalFee"].ToString());
                }
                else
                {
                    reader.Close();
                    Msg.StatusCode = 403;
                    Msg.Status = "FAILURE";
                    Msg.ErrorMsg = "Transaction Failed";
                    Msg.message = "Transaction is not Found/Paid.";
                    goto XXX;
                }
                reader.Close();
                //Check the amount
                if(PayAmount != decimal.Parse(amount))
                {
                    Msg.StatusCode = 403;
                    Msg.Status = "FAILURE";
                    Msg.ErrorMsg = "Transaction Failed";
                    Msg.message = "The Amount is not equal.";
                    goto XXX;
                }
                //Change the status
                com = new SqlCommand("UPDATE [dbo].[BillData] SET PayStatus = 'Paid', PayDate = '" + paid_dt + "', PayMethod = '" + paid_at + "', PayerInfo = '" + payee_mobile + "', BankRefNo = '" + RefNo + "' WHERE BillId IN ( SELECT B.BillId FROM [dbo].[BillData] B, [CustomerInfo] C WHERE B.Customer = C.CustId AND C.CustomerId = '1234' AND B.PayStatus = 'Unpaid')", con);
                reader = com.ExecuteReader();
                reader.Close();
                Msg.StatusCode = 200;
                Msg.Status = "SUCCESS";
                Msg.ErrorMsg = "None";
                Msg.message = "The Bill has been Paid Successfuly.";
            }
            catch (WebException ex)
            {
                Msg.StatusCode = 404;
                Msg.Status = "FAILURE";
                Msg.ErrorMsg = "Transaction Failed";
                Msg.message = "Id is Not Found.";
            }
        XXX:
            return Msg;
        }


        public async Task<SafariMsg> Safricom_AirTime_API(string Biller, string Bill, string api_key, string api_secret, string url)
        {
            string[] PostStatus = new string[10];
            ResponseMsg Msg = new ResponseMsg();
            SafariMsg X = new SafariMsg();
            string json = null;
            url = "https://102.218.49.85:7001/auth/v1/prepayBalance/eTopup";
            //get the account number and chcek 
            string AccountNo = null;
            try
            {
                var client = new HttpClient();
                var request = new HttpRequestMessage(HttpMethod.Post, "https://102.218.49.85:7001/auth/v1/prepayBalance/eTopup");
                request.Headers.Add("Authorization", "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJTRkMgQXV0b21hdGlvbiIsImF1ZCI6IlBST0QiLCJpc3MiOiJTYWZhcmljb20iLCJleHAiOjE2OTk2MzA0OTMsImlhdCI6MTY5OTYwMDQ2MywidXNlcm5hbWUiOiJQUkVUVVBTIn0._PdqjZmXd6P-deUzjs5pz0SBaNK0slJ0PXgtNxeapN7bxlSayc44R026XjotzsTj_AR2PSj92AcPLyzILXe-AQ");
                request.Headers.Add("x-source-system", "PRETUPS");
                request.Headers.Add("x-route-id", "warehouse");
                request.Headers.Add("x-correlation-id", "R230201.1102.410001_TEST-5e39fe1d-6671-4c43-b954-01b7358f4dc4");
                var content = new StringContent("{\r\n    \"type\":\"CustomerRecharge\",\r\n    \"id\":[\r\n       {\r\n          \"value\":\"251799462244\",\r\n          \"schemeName\":\"MSISDN\"\r\n       },\r\n       {\r\n          \"value\":\"2580\",\r\n          \"schemeName\":\"PIN\"\r\n       }\r\n    ],\r\n    \"password\" : \"2580\",\r\n    \"payment\":{\r\n       \"customerReference\":\"251700404991\",\r\n       \"customerReferenceType\":\"ServiceNumber\",\r\n       \"customerName\":\"Muluken Kindachew\",\r\n       \"date\":\"{{$right_now}}\",\r\n       \"paymentDetails\":{\r\n          \"transactionId\":\"BOA-b31bb3ba-094b-4366-bca2-97eff63c8dcb\",\r\n          \"amountPaid\":\"10\"\r\n       }\r\n    }\r\n }\r\n \r\n", null, "application/json");
                request.Content = content;
                var response = await client.SendAsync(request);
                response.EnsureSuccessStatusCode();
                X.message = await response.Content.ReadAsStringAsync();

            }
            catch (WebException ex)
            {
                Msg.StatusCode = 404;
                Msg.Status = "FAILURE";
                Msg.ErrorMsg = "Transaction Failed";
                Msg.message = "Id is Not Found.";
            }
            return X;
        }

        public string CheckAccountBalancefromCBS(string accountNumber, string amount)
        {
            try
            {
                // Prepare the API endpoint URL with the required query parameters
                var apiUrl = "http://10.10.13.201:7076/API/DemoWebService.asmx/AccountInfoRequest?AccountNo={accountNumber}&ExtRefNo=1234&UserId=ESB001&Password=Dgb@123&ServiceCode=ESBTLBO&NameBal={amount}";

                // Create HttpClient instance to send the request
                using (var client = new HttpClient())
                {
                    // Send the GET request to the API
                    HttpResponseMessage response = client.GetAsync(apiUrl).Result;

                    // Check if the request was successful
                    if (response.IsSuccessStatusCode)
                    {
                        // Read the response content as a string
                        string responseContent = response.Content.ReadAsStringAsync().Result;

                        // Assuming the API returns the balance info as a string in the response
                        return responseContent;
                    }
                    else
                    {
                        // Handle the API error response if needed
                        return "Error occurred while checking account balance.";
                    }
                }
            }
            catch (HttpRequestException ex)
            {
                // Handle any exceptions that may occur during the API request
                // For simplicity, you can just return an error message
                return "Error occurred while checking account balance: " + ex.Message;
            }
        }
        public void RetriveMiniStatement(string AccNumber, DateTime DateFrom, DateTime DateTo)
        {
            string CustName = null;
            decimal CustBal = (decimal)0.00;
            string Currency = null;
            string RefNo = null;
            string AccountCategaory = null;
            string OperationName = null;
            string url = "http://10.1.200.153:7003/FCUBSAccService/FCUBSAccService";
            //if the account is GL
            HttpWebRequest request = null;
            XmlDocument SOAPReqBody = new XmlDocument();
            //url = GetAPIParameters("IFB", "Fetch", "URL");
            request = (HttpWebRequest)WebRequest.Create(@url);
            request.Headers.Add(@"SOAP:Action");
            request.ContentType = "text/xml;charset=\"utf-8\"";
            request.Accept = "text/xml";
            request.Method = "POST";
            //<fcub:USERID>ABELMT</fcub:USERID>  //Test
            //<fcub:USERID>TELEBIRRBR</fcub:USERID>  //Prod
            SOAPReqBody.LoadXml(@"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:fcub=""http://fcubs.ofss.com/service/FCUBSAccService"">
               <soapenv:Header/>
               <soapenv:Body>
                  <fcub:QUERYCUSTACCTXN_IOFS_REQ>
                     <fcub:FCUBS_HEADER>
                        <fcub:SOURCE>VTM</fcub:SOURCE>
                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>           
                        <fcub:USERID>EBISSAG</fcub:USERID>           
                        <fcub:BRANCH>000</fcub:BRANCH>       
                        <fcub:SERVICE>FCUBSAccService</fcub:SERVICE>
                        <fcub:OPERATION>QueryCustAccTxn</fcub:OPERATION>     
                     </fcub:FCUBS_HEADER>
                     <fcub:FCUBS_BODY>
                        <fcub:Query-Details-IO>
                           <fcub:ACCNO1>1091100332081</fcub:ACCNO1>
                            <fcub:FROMDATE>2024-01-20</fcub:FROMDATE>
                           <fcub:TODATE>2024-01-30</fcub:TODATE>
                           <fcub:NO_OF_TRNS>20</fcub:NO_OF_TRNS>
			            <fcub:ACTION_ORDER>D</fcub:ACTION_ORDER>
                        </fcub:Query-Details-IO>
                     </fcub:FCUBS_BODY>
                  </fcub:QUERYCUSTACCTXN_IOFS_REQ>
               </soapenv:Body>
            </soapenv:Envelope>");
            //check connection
            url = url.Replace("//", "*");
            string IP = ExtractData(0, ":", "*", ":", url);
            if (PingStatus(IP) != "Success")
            {
                //PostStatus[0] = "-1";
                //PostStatus[1] = "Connection Timeout";
                //goto XXX;
            }

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
            using (Stream stream = request.GetRequestStream())
            {
                SOAPReqBody.Save(stream);
            }

            using (WebResponse Serviceres = request.GetResponse())
            {
                using (StreamReader rd = new StreamReader(Serviceres.GetResponseStream()))
                {
                    string ServiceResult = rd.ReadToEnd();
                    //string xmlData = @"<Customer><FirstName>John</FirstName><LastName>Doe</LastName><Age>30</Age></Customer>";

                    XmlSerializer serializer = new XmlSerializer(typeof(MiniStatement));
                    using (StringReader reader = new StringReader(ServiceResult))
                    {
                        MiniStatement mini = (MiniStatement)serializer.Deserialize(reader);
                        Console.WriteLine(mini.TRNREF);  
                    }
                }
            }
        }
    
        public decimal CheckLimit(string accountNumber, decimal Amount, string ServiceCode)
        {
            try
            {
                int ServiceId = 0;
                string CIF = accountNumber.Substring(5,7);
                decimal Limit = (decimal)25000;
                decimal TodayTxn = (decimal)0;
                string TxnDate = DateTime.Today.ToString("yyyy-MM-dd");
                TeleBirrTestDBEntities db = new TeleBirrTestDBEntities();
                APIMethod API = db.APIMethods.Where(s => s.Service1.ServiceCode == ServiceCode && s.MethodName == "Post").FirstOrDefault();
                ServiceId = API.Service;
                if(Regex.IsMatch(API.Description, @"\d"))
                    Limit = decimal.Parse(API.Description.ToString());
                else
                    Limit = (decimal)100000;
                SqlCommand com = null;
                SqlDataReader reader = null;
                SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["Connection2"].ConnectionString);
                con.Open();
                com = new SqlCommand("SELECT M.MethodId, CONVERT(DATE,F.TxnDate),S.ServiceCode,SubString(F.FromAccNo,6,7), SUM(F.Amount) AS TodayTxn FROM FundTransfer F, [Services] S, APIMethods M " +
                    "WHERE F.[Service] = S.ServiceId AND M.[Service] = S.ServiceId AND M.[Service] = " + ServiceId + " AND M.MethodName = 'POST' AND " +
                    "SubString(F.FromAccNo,6,7) = '" + CIF + "' AND CONVERT(DATE,F.TxnDate) = '" + TxnDate + "' AND F.Status = 'Approved' " +
                    "GROUP BY M.MethodId, CONVERT(DATE,F.TxnDate),S.ServiceCode,SubString(F.FromAccNo,6,7);", con);
                reader = com.ExecuteReader();
                if (reader.HasRows)
                {
                    reader.Read();
                    TodayTxn = decimal.Parse(reader["TodayTxn"].ToString());
                }
                reader.Close();
                if (Limit <= TodayTxn)
                    return (decimal)-1; // Already pass the limit, can not do transaction
                else if (Limit >= (TodayTxn + Amount))
                    return (decimal)0; // possible to send transaction
                else
                    return (decimal)(Limit - TodayTxn); // Only this amount is possible to send
            }
            finally
            {
                //con.Close();
            }
        }


        

    }
}
