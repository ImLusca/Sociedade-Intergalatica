import React from 'react';
import { useState } from 'react';
import Styles from './Addcommunity.module.css'
import axios from 'axios';
import Cookies from "js-cookie"

const AddCommunity = () => {
    
    const [especie, setEspecie] = useState("");
    const [comunidade, setComunidade] = useState("");

    const addItem = async ()=>{
        try {
            const response = await axios.post('http://127.0.0.1:5000/insereParticipa', {
                especie: especie,
                comunidade: comunidade,
                faccao: Cookies.get("userFaction"),
            });
            
            if (response.status === 200) {
                alert('Comunidade adicionada!');
                setEspecie("");
                setComunidade("");
            }
        } catch (error) {
            if(error.response?.status == 500){
                alert(error.response?.data?.error);
                return
            }
            alert(`Erro: ${error}`);
        }
    }
    return (
        <>
            <h3>Adicionar comunidade</h3>
            <div className={Styles.container}>
                <input type="text" value={comunidade} placeholder='comunidade' onChange={(e)=>setComunidade(e.target.value)} />
                <input type="text" value={especie} placeholder='espécie' onChange={(e)=>setEspecie(e.target.value)}/>
                <button onClick={addItem}>Adicionar</button>
            </div>
        </>
    );
};

export default AddCommunity;
