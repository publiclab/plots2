require 'rails_helper'

describe "banning a spammer" do

    it "changes liked_by value on a note" do
        
        spam_user = User.new({username:'spammer', email: 'test@test.com', password: 'publiclab', password_confirmation: 'publiclab'})
        assert spam_user.save({})
        spam_uid = spam_user.uid
    
        writer_user = User.new({username:"writer", email: "writer@test.com", password: "publiclab", password_confirmation: "publiclab"})
        assert writer_user.save({})
        writer_uid = writer_user.uid
        
        research_note = DrupalNode.new({type:"note", title: "NicePost", uid: writer_uid})
        assert research_note.save
        research_note_nid = research_note.nid
        
        spam_user.drupal_user.add_like(research_note_nid, true)
        expect { spam_user.drupal_user.ban }.to change {DrupalNode.where(nid: research_note_nid).first.liked_by(spam_uid)}
    end    
end