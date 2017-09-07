

import UIKit
import MyCheckCore


protocol AddMasterPassBusinessLogic
{
    
    func setup(request:AddMasterPass.Setup.Request)
    
    func getMasterpassToken(request:AddMasterPass.GetMasterpassToken.Request)

    
    func addMasterpass(request: AddMasterPass.AddMasterpass.Request)
    
    
    
}

protocol AddMasterPassDataStore
{
}


struct AddMasterPassInteractorModel{
    var initPayload: MasterPassInitPayload?

}


class AddMasterPassInteractor: AddMasterPassBusinessLogic, AddMasterPassDataStore
{
    func setup(request: AddMasterPass.Setup.Request) {
        self.model.initPayload = request.payload
    }


    
    
    
    
    
    var presenter: AddMasterPassPresentationLogic?
    var model : AddMasterPassInteractorModel  = AddMasterPassInteractorModel()
    
    
    func addMasterpass(request: AddMasterPass.AddMasterpass.Request) {
        let response = AddMasterPass.AddMasterpass.Response(complitionStatus: request.complitionStatus)
        presenter?.addedMasterpass(response: response)
    }
    
    func getMasterpassToken(request: AddMasterPass.GetMasterpassToken.Request) {
        guard let payload = model.initPayload else{
            //to-do fail
            return
        }
       
            let response = AddMasterPass.GetMasterpassToken.Response(callback: request.callback, payload: payload)
        
        presenter?.getMasterpassToken(response: response)
    }

}


