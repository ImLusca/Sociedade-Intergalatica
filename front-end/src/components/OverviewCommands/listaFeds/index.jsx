import React ,{useState} from 'react';
import Styles from './listaFeds.module.css';

const ListaFederacoes = () => {
    
    const Federations =['Federação 1', 'Federação 2', 'Federação 3', 'Federação 4', 'Federação 5']

    const changeFed = (leader)=>{
        window.confirm(`deseja indicar ${leader} como novo lider?`)
    }
    
    return (
        <>
            <h3>Federações</h3>
            <div className={Styles.container}>
                {Federations.map((fed)=>(
                    <div className={Styles.item} onClick={()=>{changeFed(fed)}}>{fed}</div>
                ))}
            </div>
        </>
    );
};

export default ListaFederacoes;
