import { LightningElement, wire, track } from 'lwc';
import getMessagesList from '@salesforce/apex/SalesHD_Homepage.getMessagesLWC';

export default class HD_Messages extends LightningElement {
    @wire(getMessagesList) messages;
}