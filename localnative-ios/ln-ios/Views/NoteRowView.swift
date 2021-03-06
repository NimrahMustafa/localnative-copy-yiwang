//
//  NoteRowView.swift
//  localnative-ios
//
//  Created by Yi Wang on 4/12/20.
//  Copyright Â© 2020 Yi Wang. All rights reserved.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct NoteRowView: View {
    var note: Note
    @Binding var query: String
    @State private var showingAlert = false
    @State private var showingQRCode = false
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Button(action:{
                    self.showingAlert = true
                }){
                    Text("X")
                }.alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Do you really want to delete this item \(String(note.uuid4.prefix(5))).. \(String(note.id))?"),
                        message: Text("There is no undo"),
                        primaryButton: .destructive(Text("Delete")){
                            AppState.ln.run(json_input:"""
                                {"action":"delete","rowid":\(self.note.id),"query":"\(AppState.getQuery())","limit":10,"offset":\(AppState.getOffset())}
                                """
                            )
                            AppState.search(input: AppState.getQuery(), offset: AppState.getOffset())
                        },
                        secondaryButton: .cancel()
                    )
                }.foregroundColor(.red).buttonStyle(BorderlessButtonStyle())
                Spacer()
                ForEach(note.tags.split(separator: ","), id:\.self){
                    tag in
                    Text(tag).onTapGesture {
                        self.query = String(tag)
                        AppState.clearOffset()
                        AppState.search(input: String(tag), offset: 0)
                    }.foregroundColor(.blue)
                }
                Text("QR").onTapGesture {
                    self.showingQRCode.toggle()
                }.sheet(isPresented: $showingQRCode){
                    QRCodeView(note: self.note, image: self.generateQRCode(from: self.note.url))
                }.foregroundColor(.white).background(Color.gray)
            }
            HStack{
                Text(note.created_at.prefix(19))
                Spacer()
                Text("\(String(note.uuid4.prefix(5))).. \(String(note.id))")
            }
            Text(makeText(note: note))
            Text(note.url).onTapGesture {
                UIApplication.shared.open(URL(string: self.note.url)!)
            }.foregroundColor(.blue)
        }
    }
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    func makeText(note: Note) -> String{
        return note.title
            + newLineOrEmptyString(str: note.description)
            + newLineOrEmptyString(str: note.annotations)
    }
    func newLineOrEmptyString(str: String) -> String{
        if(str.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            return ""
        }else{
            return "\n" + str
        }
    }
}

struct NoteRowView_Previews: PreviewProvider {
    static var previews: some View {
        NoteRowView(note: Note(
            id: 0,
            uuid4: "uuid4",
            title: "title",
            url: "url",
            tags: "tag1,tag2",
            description: "description",
            annotations: "annotations",
            created_at: "2020-04-12"
        ), query: .constant("query"))
    }
}
