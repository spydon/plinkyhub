alter table banks rename to packs;
alter table bank_slots rename to pack_slots;
alter table pack_slots rename column bank_id to pack_id;
