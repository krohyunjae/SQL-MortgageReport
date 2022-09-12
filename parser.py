
from asyncore import write
import math
import os
import random
import sys
import datetime
from datetime import timedelta
import random
from json import loads
from re import sub

columnSeparator = "|"


# Dictionary of months used for date transformation
MONTHS = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',\
        'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'}

"""
Returns true if a file ends in .json
"""
def isJson(f):
    return len(f) > 5 and f[-5:] == '.json'

"""
Converts month to a number, e.g. 'Dec' to '12'
"""

def transformMonth(mon):
    if mon in MONTHS:
        return MONTHS[mon]
    else:
        return mon

"""
Transforms a timestamp from Mon-DD-YY HH:MM:SS to YYYY-MM-DD HH:MM:SS
"""
def transformDttm(dttm):
    dttm = dttm.strip().split(' ')
    dt = dttm[0].split('-')
    date = '20' + dt[2] + '-'
    date += transformMonth(dt[0]) + '-' + dt[1]
    return date + ' ' + dttm[1]

"""
Transform a dollar value amount from a string like $3,453.23 to XXXXX.xx
"""

def transformDollar(money):
    if money == None or len(money) == 0:
        return money
    return sub(r'[^\d.]', '', money)

attributes = ["firstname","lastname","street","state","city","email","gender","contact"]


member_table_attributes = ["firstName", "lastName", "ssn", "creditScore", "addressId", "email", "contactNumber", "isMarried", "age", "gender"]

member_table = []; 

address_attributes = ["addressId","state","city","streetAddress","zipcode","fullAddress"]
address_table = []


memberfinance_table = []

memberfinance_attributes = ["memberId","creditScore","yearsEmployment","annualIncome","incomeVerified","dtiRatio","lengthCreditHistory",
"numTotalCreditLines","numOpenCreditLinesLastYear","revolvingBalance","revolvingUtilizationRate","numDeregatoryRec","numDelinquency2Years","numChargeOffLastYear","numInquiries6Mon"]

loan_table = []
loan_attributes = ["loanId","memberId","date","purpose","isJointApplication","laonAmount","paymentTerm","interestRate","monthlyPayment","loanGrade","loanStatus"]

category_table = set()

category_table_attributes = ["ItemID", "Category"]

check_ID = []
unique_item_ID= set(check_ID)
unique_user_pair = {}

def writeFile(file, table):
# Writes contents of the tables to the .dat file, separated by the column separator 
    for i in range(len(table)):
        for j in range(len(table[i])):
            if(table[i][j] is None):
                print(table[i][j-1])
                break
            if(j == len(table[i])-1):
                file.write(str(table[i][j]) + '\n')
            else :
                file.write(str(table[i][j]) + columnSeparator)

# Returns index of x in list if present, else -1 
def binarySearch (list, l, r, x): 
    if r >= l: 
        mid = l + (r - l)/2
        if list[mid] == x: 
            return mid 
        elif list[mid] > x: 
            return binarySearch(list, l, mid-1, x)
        else: 
            return binarySearch(list, mid+1, r, x) 
    else:
        return -1

def dictionary_to_listay(file,pairs):
    
    for pair in pairs.keys():
        file.write(pair + columnSeparator)
        file.write(pairs[pair][0]+ columnSeparator)
        file.write(pairs[pair][1]+ columnSeparator)
        file.write(pairs[pair][2] + "\n")
    return 0

def createDB():
    member = "member.dat"
    address = "address.dat"
    mf = "memberFinance.dat"
    loan = "loan.dat"
    if os.path.exists(member):
        memberaw = 'a'
    else:
        memberaw = 'w'
    if os.path.exists(address):
        addressaw = 'a'
    else:
        addressaw = 'w'
    if os.path.exists(mf):
        mfaw = 'a'
    else:
        mfaw = 'w'
    if os.path.exists(loan):
        loanaw = 'a'
    else:
        loanaw = 'w'
    memberf = open(member,memberaw)
    writeFile(memberf, member_table)
    memberf.close()
    addressf = open(address, addressaw)
    writeFile(addressf, address_table)
    addressf.close()
    mff = open(mf, mfaw)
    writeFile(mff,memberfinance_table)
    mff.close()

    loan = open(loan, loanaw)
    writeFile(loan,loan_table)
    loan.close()
    

def quotation(with_quotation):
    temp =  with_quotation.replace("\"", "\"\"")
    return "\"" +temp + "\""



def parseJson(json_file):
    with open(json_file, 'r') as f:
        items = loads(f.read())['objects'] # creates a Python dictionary of Items for the supplied json file
        index = 0
        for item in items:
            """
            traverse the items dictionary to extract information from the
            given `json_file' and generate the necessary .dat files to generate
            the SQL tables
            """
            index += 1
            firstName = item["firstname"]
            lastName = item["lastname"]
            street = item["street"]
            state = item["state"]
            city = item["city"]
            email = item["email"]
            contact = item["contact"]
            creditscore = creditScore()
            # Populating random data
            married = bool(random.getrandbits(1))
            age = random.randint(27,55)
            yearsEmployment = age-random.randint(20,25)
            creditHistory = age-random.randint(24,25)
            creditLines = round(clamp(random.normalvariate(1,3),1,8))
            openCreditLinesLastYear = round(clamp(creditLines- random.randrange(0,3),0,8))
            revolvingBalance = clamp(random.normalvariate(13000,5000),0,sys.maxsize)
            revolvingUtilizationRate = revolvingBalance/(creditLines * random.randrange(5000,10000))
            numDeregRec = round(clamp(random.normalvariate(5,5)-5,0,20))
            numDeliquency = round(clamp(random.normalvariate(5,5)-5,0,20))
            numChargeOff = round(clamp(random.normalvariate(5,5)-6,0,20))
            numCreditInquiry = round(clamp(random.normalvariate(5,5)-10,0,20))
            loanAmount = random.randrange(100000,450000)
            paymentTerm = random.randrange(15,30)
            interestRate = round(clamp(random.normalvariate(0.03,0.05),0.025,0.1),4)
            monthlyInterest = round(interestRate/12,4)
            termMonths = paymentTerm*12
            monthlyPayment = round(loanAmount * (monthlyInterest * (1+monthlyInterest)**termMonths) / ((1+monthlyInterest)**termMonths-1),2)
            # Population end
            # Note - the current dataset only contains 1-1 relation and inserting into multiple tables(files) in a single
            # loop works but with different dataset this needs to be changed
            
            # member table
            temp_member_table = []
            # memberId
            temp_member_table.append(index)
            temp_member_table.append(firstName)
            temp_member_table.append(lastName)
            temp_member_table.append(createSSN())
            # addressId
            temp_member_table.append(index)
            temp_member_table.append(creditscore)
            temp_member_table.append(email)
            temp_member_table.append(contact[-12:])
            temp_member_table.append(married)
            temp_member_table.append(age)
            temp_member_table.append(random.choice(["male","female"]))
            member_table.append(temp_member_table)

            # address table
            temp_address_table = []
            # addressId
            temp_address_table.append(index)
            temp_address_table.append(state)
            temp_address_table.append(city)
            temp_address_table.append(street)
            temp_address_table.append(random.randint(10001,99950))
            address_table.append(temp_address_table)
            # memberfinance table
            temp_memberfinance_table = []
            # memberfinanceId & memberId
            temp_memberfinance_table.append(index)
            temp_memberfinance_table.append(index)
            temp_memberfinance_table.append(creditscore)
            # years of employment
            temp_memberfinance_table.append(yearsEmployment)
            # annual income
            temp_memberfinance_table.append(getIncome(age))
            # incomeVerified
            temp_memberfinance_table.append(1)
            # dtiRatio
            temp_memberfinance_table.append(random.random())
            # Credit History
            temp_memberfinance_table.append(creditHistory)
            # Credit Lines
            temp_memberfinance_table.append(creditLines)
            # open credit lines last year
            temp_memberfinance_table.append(openCreditLinesLastYear)
            # revolving balance
            temp_memberfinance_table.append(revolvingBalance)
            # revolving utilization rate
            temp_memberfinance_table.append(revolvingUtilizationRate)
            # number of deregatory records
            temp_memberfinance_table.append(numDeregRec)
            # number of deliquency in 2 years
            temp_memberfinance_table.append(numDeliquency)
            # number of charge off last year
            temp_memberfinance_table.append(numChargeOff)
            # number of credit inquiries in 6 month
            temp_memberfinance_table.append(numCreditInquiry)
            memberfinance_table.append(temp_memberfinance_table)
            
            # loan table
            temp_loan_table = []
            # loanId and memberId
            temp_loan_table.append(index+10000000)
            temp_loan_table.append(index)
            # application date
            temp_loan_table.append(ranDate())
            # purpose
            temp_loan_table.append("mortgage")
            # is it joint application? 
            temp_loan_table.append(married)
            # loan amount
            temp_loan_table.append(loanAmount)
            # payment term
            temp_loan_table.append(paymentTerm)
            # interest rate
            temp_loan_table.append(interestRate)
            # monthly payment
            temp_loan_table.append(monthlyPayment)
            # loan grade - calculated once bulk loading completes 
            temp_loan_table.append("")
            # loan status
            temp_loan_table.append("")
            loan_table.append(temp_loan_table)

def createSSN():
    return random.randint(100000000,999999999)
def creditScore():
    return round(clamp(random.normalvariate(700,50),350,850))
def clamp(n, minval, maxval):
    return max(minval, min(n,maxval))
def getIncome(age):
    if(age < 35):
        return random.normalvariate(34371,5000)
    elif(age < 45):
        return random.normalvariate(50001,6000)
    elif(age < 55):
        return random.normalvariate(52000,5000)
    else:
        return random.normalvariate(54299,7000)
def ranDate():
    today = datetime.datetime.today().date()
    delta = timedelta(days= random.randint(1,90))
    appldate = today-delta
    return appldate


"""
Loops through each json files provided on the command line and passes each file
to the parser
"""
def main(argv):
    if len(argv) < 2:
        print('Usage: python parser.py <path to json files>')
        sys.exit(1)
    # loops over all .json files in the argument
    for f in argv[1:]:
        if isJson(f):
            parseJson(f)
            print ("Success parsing " + f)
            break
    createDB()

if __name__ == '__main__':
    main(sys.argv)