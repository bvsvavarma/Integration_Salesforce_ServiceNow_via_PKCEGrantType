import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import fetchAuthUrl from '@salesforce/apex/ServiceNowAuthController.fetchAuthUrl';
import getAccessToken from '@salesforce/apex/ServiceNowAuthController.exchangeAuthCodeForToken';

export default class ServiceNowAuthInitiator extends LightningElement {

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('currentPageReference'+currentPageReference);
        if (currentPageReference) {
                console.log('current Page Reference'+JSON.stringify(currentPageReference));
                let code = currentPageReference.state?.c__code;
                getAccessToken({authCode : code})
                    .then((response)=>{
                        console.log('Varma Response '+response);
                    })
                    .catch((error)=> {
                        console.log('Varma Error '+error);
                    });
            }
    }
    handleAuthenticate(){
        //calls Controller method it returns auth URL
        fetchAuthUrl()
            .then((response) => {
                console.log('response: '+response);
                window.location.href = response;
            })
            .catch((error) => {
                console.log('error: '+ error)
            });
    }
}