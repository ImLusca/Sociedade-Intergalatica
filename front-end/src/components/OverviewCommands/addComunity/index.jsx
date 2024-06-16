import React from 'react';
import Styles from './Addcommunity.module.css'

const AddCommunity = () => {
    
    const addItem = ()=>{
        window.confirm(`deseja adicionar essa comunidade à facção?`)
    }
    
    return (
        <>
            <h3>Adicionar comunidade</h3>
            <div className={Styles.container}>
                <input type="text" placeholder='comunidade'/>
                <input type="text" placeholder='espécie'/>
                <button onClick={addItem}>Adicionar</button>
            </div>
        </>
    );
};

export default AddCommunity;
