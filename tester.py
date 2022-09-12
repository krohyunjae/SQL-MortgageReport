import datetime
import random



def main():
    loanAmount = random.randrange(100000,450000)
    paymentTerm = random.randrange(15,30)
    print(paymentTerm)
    interestRate = clamp(random.normalvariate(0.03,0.05),0.025,0.1)
    print(interestRate)
    termMonths = paymentTerm*12
    periodicInterest = round(interestRate/12,4)
    print(termMonths)
    print(loanAmount)
    monthlyPayment = loanAmount / (((1+periodicInterest)**termMonths)-1)
    print(monthlyPayment)
    monthlyPayment = monthlyPayment / (periodicInterest*((1+periodicInterest)**termMonths))
    print(monthlyPayment)
    


    monthlyPayment = loanAmount * (periodicInterest * (1+periodicInterest)**termMonths) / ((1+periodicInterest)**termMonths-1)
    print(monthlyPayment)
def clamp(n, minval, maxval):
    return max(minval, min(n,maxval))

if __name__ == '__main__':
    main()